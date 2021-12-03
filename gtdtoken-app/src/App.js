import logo from './logo.svg';
import Web3 from 'web3';
import React, { Component } from 'react';
import { GTDTokenABI, GTDTokenAddress } from './config';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import './App.css';
import { ethers } from 'ethers';



class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      queueLength: 0,
      owner: '0x13b77Ad9Fc0f921dB4b1D0b3eE8f9A7F50BbDA2D',
      account: '',
      newStock: 0,
      addressBalance: '',
      ether: ''
    }
  }
  componentDidMount() {
    this.loadBlockChainData();
  }

  async loadBlockChainData() {
    const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
    const network = await web3.eth.net.getNetworkType();
    console.log("network", network);

    //Account Current
    //window.ethereum.enable();
    const accounts = await web3.eth.getAccounts();
    this.setState({ account: accounts[0] });
    console.log("Account", accounts[0]);
    //Load Token ABI
    const GTDToken = new web3.eth.Contract(GTDTokenABI, GTDTokenAddress);
    this.setState({ GTDToken });
    console.log("Token", GTDToken);
    //Call QueueLength
    this.fetchQueueLength();
    //Call Owner 
    this.fetchOwner();
  }
  async fetchQueueLength() {

    const queueLength = await this.state.GTDToken.methods.getQueueLength().call();
    this.setState({ queueLength: queueLength });
    console.log("Queue Length is ", queueLength);
  }
  async fetchOwner() {

    const owner = await this.state.GTDToken.methods.getOwner().call();
    this.setState({ owner: owner });
    console.log(owner);
  }

  expressInterest = async () => {
    await this.state.GTDToken.methods.expressInterest().send({
      from: this.state.account,
    });
    this.fetchQueueLength();
  }

  initiateSelling = async () => {
    await this.state.GTDToken.methods.initiateSelling().send({
      from: this.state.owner,
    });
    this.fetchQueueLength();
  }

  addNewStock = async (e) => {
    e.preventDefault();
    const { newStock } = this.state;
    if (newStock > 0) {
      await this.state.GTDToken.methods.addNewStock(newStock).send({
        from: this.state.owner,
      });
    }
  }

  balanceOf = async () => {
    const { addressBalance } = this.state
    const tokenBalance = await this.state.GTDToken.methods.balanceOf(addressBalance).call();
    console.log("Token Balance is :", tokenBalance);
  }

  handleChange = (e) => {
    const { name, value } = e.target;
    this.setState({ [name]: value })
  }

  sendEthers = async (e) => {
    try {
      const { owner, ether } = this.state;
      let ethereum = window.ethereum;
      await ethereum.send("eth_requestAccounts");
      let provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      ethers.utils.getAddress(owner);
      const params = {
        to: owner,
        value: ethers.utils.parseEther(ether)
      };

      const transaction = await signer.sendTransaction(params);
      console.log('transactionHash is ' + transaction);
    }
    catch (error) {
      console.log(error.message);
    }

  }



  render() {
    return (
      <div className="App">
        <h1> GTD Token App </h1>


        <Button variant="outline-info" size="lg" onClick={this.expressInterest}>
          Express Interest
        </Button>

        <div>
          <br></br>

          <Form.Control name='addressBalance' size="lg" type="text" placeholder="Enter address to view the token balance" onChange={this.handleChange} />


          <br></br>

          <Button variant="outline-info" size="lg" onClick={this.balanceOf}>
            Check Token Balance
          </Button>
        </div>




        {this.state.account === this.state.owner ?
          <div>
            <br></br>
            <Button variant="outline-info" size="lg" onClick={this.initiateSelling}>
              Initiate Selling
            </Button>
            <br></br>

            <Form.Control name='newStock' size="lg" type="text" placeholder="Enter New Stock Value" onChange={this.handleChange} />

            <br></br>

            <Button variant="outline-info" size="lg" onClick={this.addNewStock}>
              Add New Stock
            </Button>



          </div>
          : <div>

            <br></br>

            <Form.Control name='ether' size="lg" type="text" placeholder="Enter ether value" onChange={this.handleChange} />


            <br></br>

            <Button variant="outline-info" size="lg" onClick={this.sendEthers}>
              Donate Ethers
            </Button>
          </div>
        }
      </div>
    )

  }

}

export default App;
