import React, { Component } from 'react';

class Comp3 extends Component {
    constructor(props) {
        super(props);
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

        // let expectedFrequency = 0
        // for (let i = min; i <= max; i++) {
        //     if (i % number == 0) {
        //         expectedFrequency += 1
        //     }
        // }
        // expectedFrequency /= (max - min + 1)
        let expectedFrequency = 1 / number;

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

    getRatesDictionary = (previous, minMultiple, maxMultiple, minNumber, maxNumber) => {
        let dico = {};
        for (let i = minMultiple; i <= maxMultiple; i++) {
            dico[i] = this.frequencyRateMultipleOf(previous, i, minNumber, maxNumber);
        }
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

        maxIndexes.forEach(m => {
            console.log(m, "-->", ratesDico[m]);
        })
    }

    render() {
        let p = this.getPrevious(1, 49, 1000);
        console.log(p);
        let dico = this.getRatesDictionary(p, 2, 49, 1, 49);
        console.log(dico);
        this.getMoreProbables(5, dico);
        console.log(this.randint(1, 49));
        console.log(this.randint(1, 49));
        console.log(this.randint(1, 49));
        console.log(this.randint(1, 49));
        console.log(this.randint(1, 49));
        return <p>ok</p>
    }
}

export default Comp3;