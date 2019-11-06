import React from 'react';
import logo from './logo.svg';
import './App.css';
import Comp1 from './comp1';
import Comp2 from './comp2';
import Comp3 from './comp3';

function App() {
  let table = [];
  for (let i = 0; i <= 100; i++) {
    table.push(i);
  }
  return (
    <Comp3></Comp3>
  );
}

export default App;
