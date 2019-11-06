import React, { Component } from 'react';

class ProgressBar extends Component {
    constructor(props) {
        super(props);
        this.state = {
            with: 0,
        }
    }

    getColorString = (percent, opacity) => {
        let red = percent <= 50 ? 255 : parseInt(255 - (2.55 * 2 * (percent - 50)));
        let green = percent <= 50 ? parseInt(2.55 * 2 * percent) : 255;
        return 'rgba(' + red + ',' + green + ',0,' + opacity + ')';
    }

    render() {
        return <div style={{ 'display': 'flex', 'flexDirection': 'row', 'width': '100%', 'height': '100%' }}>
            <div style={{ 'width': this.props.percentage + '%', 'height': '100%', 'backgroundColor': this.getColorString(this.props.percentage, 1) }}></div>
            <div style={{ 'width': 100 - this.props.percentage + '%', 'height': '100%', 'backgroundColor': this.getColorString(this.props.percentage, 0.25) }}></div>
        </div>
    }
}

export default ProgressBar;