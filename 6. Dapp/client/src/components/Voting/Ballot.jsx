import { useState } from "react";
import useEth from "../../contexts/EthContext/useEth";

function Ballot({ setValue }) {
  const {
    state: { contract, accounts, listVoteEvent },
  } = useEth();
  const [storageProposal, setStorageProposal] = useState(null);
  console.log("storageProposal : " + storageProposal);

  const getAllProposals = async () => {
    await contract.methods
      .getAllProposals()
      .call({ from: accounts[0] })
      .then((results) => {
        setStorageProposal(results);
        console.log(storageProposal);
      })
      .catch((err) => alert(err.message));
  };

  const setVote = async (e) => {
    if (e.target.tagName === "INPUT") {
      return;
    }

    let valeur = document.getElementById("setVote").value;
    if (valeur === "") {
      alert("Please choose a proposal.");
      return;
    }
    await contract.methods.setVote(valeur).send({ from: accounts[0] });
  };

  const currentVotersBallot = (
    <>
      {storageProposal &&
        storageProposal
          .filter((item) => item.returnValues.voter === accounts[0])
          .map((votersBallot) => {
            console.log("BINGO");
            return (
              <p>
                Poposal ID = {votersBallot.returnValues.proposalId}{" "}
                TransactionHash = {votersBallot.transactionHash}
              </p>
            );
          })}
    </>
  );

  return (
    <div>
      <details>
        <summary>getAllProposals</summary>
        <div>
          <p>Allow voter registration by the owner of the contract</p>
          <button onClick={getAllProposals}>getAllProposals</button>
        </div>
        {storageProposal && (
          <table className="eventTable">
            <thead>
              <tr>
                <th>List of proposals</th>
              </tr>
            </thead>
            <tbody>
              {storageProposal.map((item, index) => (
                <tr key={index}>
                  <td>Proposal ID : {index}</td>
                  <td>Description : {item.description}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        <br />
        <br />
        {listVoteEvent.some(
          (item) => item.returnValues.voter === accounts[0]
        ) ? (
          <div>
            <p>You have already voted</p>
            {/*currentVotersBallot*/}
          </div>
        ) : (
          <div>
            <p>Select a proposal ID based on the list above</p>
            <input type="address" defaultValue="" id="setVote" size="45" />
            <button onClick={setVote}>Select your proposal</button>
          </div>
        )}
        <br />
        <br />
      </details>
    </div>
  );
}

export default Ballot;
