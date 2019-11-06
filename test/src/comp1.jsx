import React, { Component } from 'react';

class Comp1 extends Component {
    constructor(props) {
        super(props);
        this.state = {
            focused: false
        }
        this.timeoutFocus = undefined;

    }

    onFocusDiv = () => {
        console.log("focus");
        clearTimeout(this.timeoutFocus);
        this.setState({
            focused: true,
        })
    }

    onBlurDiv = () => {
        this.timeoutFocus = setTimeout(() => {
            console.log("blur");
            this.setState({
                focused: false
            });
        }, 0)
    }
    render() {
        if (this.state.focused) {
            return <div onFocus={this.onFocusDiv} onBlur={this.onBlurDiv}>
                <input autoFocus={true} type="text"></input>
                <button onClick={this.onBlurDiv}>Button</button>
            </div>
        }
        else {
            return <button onClick={this.onFocusDiv}>Edit</button>
        }
    }
}

export default Comp1;