import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as CoffeeBean_idl } from 'dfx-generated/CoffeeBean';
import { idlFactory as CoffeeFarm_idl } from 'dfx-generated/CoffeeFarm';
import { idlFactory as AuctionService_idl } from 'dfx-generated/AuctionService';
import { idlFactory as AuctionTracking_idl } from 'dfx-generated/AuctionTracking';
import { idlFactory as Retailer_idl } from 'dfx-generated/Retailer';
import { idlFactory as Roasters_idl } from 'dfx-generated/Roasters';
import { idlFactory as SmartPayment_idl } from 'dfx-generated/SmartPayment';

const agent = new HttpAgent();

const CoffeeBean = Actor.createActor(CoffeeBean_idl, { agent, canisterId: 'br5f7-7uaaa-aaaaa-qaaca-cai' });
const CoffeeFarm = Actor.createActor(CoffeeFarm_idl, { agent, canisterId: 'bw4dl-smaaa-aaaaa-qaacq-cai' });
const AuctionService = Actor.createActor(AuctionService_idl, { agent, canisterId: 'avqkn-guaaa-aaaaa-qaaea-cai' });
const AuctionTracking = Actor.createActor(AuctionTracking_idl, { agent, canisterId: 'b77ix-eeaaa-aaaaa-qaada-cai' });
const Retailer = Actor.createActor(Retailer_idl, { agent, canisterId: 'a3shf-5eaaa-aaaaa-qaafa-cai' });
const Roasters = Actor.createActor(Roasters_idl, { agent, canisterId: 'ajuq4-ruaaa-aaaaa-qaaga-cai' });
const SmartPayment = Actor.createActor(SmartPayment_idl, { agent, canisterId: 'aovwi-4maaa-aaaaa-qaagq-cai' });

function App() {
    const [batches, setBatches] = useState([]);
    const [newBatch, setNewBatch] = useState({
        id: '',
        farmLocation: '',
        certifications: [],
        timestamp: 0,
        status: ''
    });
    const [newAuction, setNewAuction] = useState({
        productId: '',
        productName: '',
        startingBid: 0,
        endTime: 0,
        batchId: ''
    });

    useEffect(() => {
        const fetchBatches = async () => {
            const result = await CoffeeBean.getBeanDetails();
            setBatches(result);
        };
        fetchBatches();
    }, []);

    const handleBatchInputChange = (e) => {
        const { name, value } = e.target;
        setNewBatch({ ...newBatch, [name]: value });
    };

    const handleAuctionInputChange = (e) => {
        const { name, value } = e.target;
        setNewAuction({ ...newAuction, [name]: value });
    };

    const handleBatchSubmit = async (e) => {
        e.preventDefault();
        const result = await CoffeeFarm.addBatch(newBatch.id, newBatch.farmLocation, newBatch.certifications, newBatch.timestamp, newBatch.status);
        console.log(result);
    };

    const handleAuctionSubmit = async (e) => {
        e.preventDefault();
        const result = await AuctionService.createAuction(newAuction.productId, newAuction.productName, newAuction.startingBid, newAuction.endTime, newAuction.batchId);
        console.log(result);
    };

    return (
        <div>
            <h1>Coffee Supply Chain</h1>
            <h2>Bean Details</h2>
            <ul>
                {batches.map((batch) => (
                    <li key={batch.batchId}>{batch.batchId}: {batch.roastLevel} from {batch.origin}</li>
                ))}
            </ul>
            <h2>Add New Batch</h2>
            <form onSubmit={handleBatchSubmit}>
                <input type="text" name="id" placeholder="Batch ID" onChange={handleBatchInputChange} required />
                <input type="text" name="farmLocation" placeholder="Farm Location" onChange={handleBatchInputChange} required />
                <input type="text" name="certifications" placeholder="Certifications (comma separated)" onChange={handleBatchInputChange} />
                <input type="number" name="timestamp" placeholder="Timestamp" onChange={handleBatchInputChange} required />
                <input type="text" name="status" placeholder="Status" onChange={handleBatchInputChange} required />
                <button type="submit">Add Batch</button>
            </form>
            <h2>Create New Auction</h2>
            <form onSubmit={handleAuctionSubmit}>
                <input type="text" name="productId" placeholder="Product ID" onChange={handleAuctionInputChange} required />
                <input type="text" name="productName" placeholder="Product Name" onChange={handleAuctionInputChange} required />
                <input type="number" name="startingBid" placeholder="Starting Bid" onChange={handleAuctionInputChange} required />
                <input type="number" name="endTime" placeholder="End Time" onChange={handleAuctionInputChange} required />
                <input type="text" name="batchId" placeholder="Batch ID" onChange={handleAuctionInputChange} required />
                <button type="submit">Create Auction</button>
            </form>
        </div>
    );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
