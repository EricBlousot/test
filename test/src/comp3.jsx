import React, { Component } from 'react';

class Comp3 extends Component {
    constructor(props) {
        super(props);
        this.state = {
            afficher: false,
            tirage: []
        }
    }


    randint = (min, max) => {
        let puiss10 = 1;
        while (puiss10 <= max) {
            puiss10 *= 10;
        }
        return (Math.trunc((Math.random() * puiss10)) % (max - min + 1)) + min
    }

    getPrevious = (min, max, len) => {
        let prev = [];
        for (let i = 0; i < len; i++) {
            prev.push(this.randint(min, max));
        }
        return prev;
    }

    frequencyRateMultipleOf = (prev, number, min, max) => {
        //console.log("prev : ", prev);

        let expectedFrequency = 0
        for (let i = min; i <= max; i++) {
            if (i % number == 0) {
                expectedFrequency += 1
            }
        }
        expectedFrequency /= (max - min + 1)

        //console.log("expected frequency of multiples of ", number, " : ", expectedFrequency);

        let realFrequency = 0;
        for (let i = 0; i <= prev.length; i++) {
            if (prev[i] % number == 0) {
                realFrequency += 1
            }
        }
        realFrequency /= prev.length
        //console.log("real frequency of multiples of ", number, " : ", realFrequency);

        let rate = expectedFrequency - realFrequency
        //console.log("rate of ", number, " : ", rate)
        return rate;
    }

    getRatesFrequencyMultiplesOfDictionary = (previous, minMultiple, maxMultiple, minNumber, maxNumber) => {
        let dico = {};
        for (let i = minMultiple; i <= maxMultiple; i++) {
            dico[i] = this.frequencyRateMultipleOf(previous, i, minNumber, maxNumber);
        }

        return dico;
    }

    getNumberFrequencyRatesDictionary = (previous, minNumber, maxNumber) => {
        let dico = {};

        for (let i = minNumber; i <= maxNumber; i++) {
            dico[i] = 0;
        }

        previous.forEach(n => {
            dico[n] += 1;
        });

        Object.keys(dico).forEach(k => {
            dico[k] = (1 / (maxNumber - minNumber + 1)) - dico[k] / previous.length;
        });

        return dico;
    }

    getMoreProbables = (howMany, ratesDico) => {
        if (howMany > Object.keys(ratesDico).length) {
            howMany = Object.keys(ratesDico).length;
        }

        let maxIndexes = []
        for (let i = 0; i < howMany; i++) {
            maxIndexes.push(undefined);
        }

        Object.keys(ratesDico).forEach(k => {
            if (maxIndexes.indexOf(undefined) >= 0) {
                maxIndexes[maxIndexes.indexOf(undefined)] = k;
            }
            else {
                let breakBool = false;
                maxIndexes.forEach((i, index) => {
                    if (ratesDico[i] < ratesDico[k] && !breakBool) {
                        maxIndexes[index] = k;
                        breakBool = true;
                    }
                });
            }
        });

        let finalDico = {}
        let total = 0;
        maxIndexes.forEach(m => {
            finalDico[m] = ratesDico[m]
            total += ratesDico[m]
        })
        maxIndexes.forEach(m => {
            finalDico[m] = Math.round(10000 * finalDico[m] / total) / 100
        })
        return finalDico;

    }
    getLessProbables = (howMany, ratesDico) => {
        if (howMany > Object.keys(ratesDico).length) {
            howMany = Object.keys(ratesDico).length;
        }

        let maxIndexes = []
        for (let i = 0; i < howMany; i++) {
            maxIndexes.push(undefined);
        }

        Object.keys(ratesDico).forEach(k => {
            if (maxIndexes.indexOf(undefined) >= 0) {
                maxIndexes[maxIndexes.indexOf(undefined)] = k;
            }
            else {
                let breakBool = false;
                maxIndexes.forEach((i, index) => {
                    if (ratesDico[i] > ratesDico[k] && !breakBool) {
                        maxIndexes[index] = k;
                        breakBool = true;
                    }
                });
            }
        });

        let finalDico = {}
        let total = 0;
        maxIndexes.forEach(m => {
            finalDico[m] = ratesDico[m]
            total += ratesDico[m];
        })
        maxIndexes.forEach(m => {
            finalDico[m] = Math.round(10000 * finalDico[m] / total) / 100
        })
        return finalDico;

    }

    crossProbables = (moreProbablesNumbers, lessProbablesNumbers, moreProbablesMultiples, lessProbablesMultiples, minNumber, maxNumber) => {
        let dico = {};
        Object.keys(moreProbablesMultiples).forEach(k => {
            let nb = parseInt(k);
            let nbs = [];
            while (nb <= maxNumber) {
                if (nb >= minNumber && !Object.keys(lessProbablesNumbers).indexOf(nb) >= 0) {
                    if (dico[nb] == undefined) {
                        dico[nb] = 0;
                    }
                    nbs.push(nb);
                }
                nb = parseInt(nb) + parseInt(k);
            }
            nbs.forEach(nb => {
                dico[nb] += moreProbablesMultiples[k] / nbs.length;
            });
        });

        Object.keys(lessProbablesMultiples).forEach(k => {
            let nb = parseInt(k);
            let nbs = [];
            while (nb <= maxNumber) {
                if (nb >= minNumber) {
                    if (dico[nb] == undefined) {
                        dico[nb] = 0;
                    }
                    nbs.push(nb);
                }
                nb = parseInt(nb) + parseInt(k);
            }
            nbs.forEach(nb => {
                dico[nb] -= lessProbablesMultiples[k] / nbs.length;
            });
        });


        Object.keys(moreProbablesNumbers).forEach(k => {
            if (dico[k] == undefined) {
                dico[k] = 0;
            }
            dico[k] += moreProbablesNumbers[k];
        });

        return dico
    }

    render() {
        if (this.state.tirage.length == 0) {
            let lenTirage = 20000;
            let prev = this.getPrevious(1, 49, lenTirage);
            let p = prev.splice(0, lenTirage - 5);
            this.setState({ tirage: prev });

            let freqDico = this.getRatesFrequencyMultiplesOfDictionary(p, 2, 49, 1, 49);
            let numberDico = this.getNumberFrequencyRatesDictionary(p, 1, 49);
            console.log(p);
            //console.log(freqDico);
            console.log("more probables multiples : ", this.getMoreProbables(5, freqDico));
            console.log("less probables multiples : ", this.getLessProbables(5, freqDico));
            console.log("more probable numbers :    ", this.getMoreProbables(5, numberDico));
            console.log("less probable numbers :    ", this.getLessProbables(5, numberDico));

            console.log("played : ", this.getMoreProbables(10, this.crossProbables(this.getMoreProbables(5, numberDico), this.getLessProbables(5, numberDico), this.getMoreProbables(5, freqDico), this.getLessProbables(5, freqDico), 1, 49)));
            console.log(prev);
        }
        return <div>
            <button onClick={() => { this.setState({ afficher: true }) }}>Afficher le tirage</button>
            {this.state.afficher && <p>{this.state.tirage[0]} - {this.state.tirage[1]} - {this.state.tirage[2]} - {this.state.tirage[3]} - {this.state.tirage[4]}</p>}
        </div>

    }
}

export default Comp3;