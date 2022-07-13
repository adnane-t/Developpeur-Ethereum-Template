import { useState } from "react";
import useEth from "../../contexts/EthContext/useEth";

function Voters({ setValue }) {
  const {
    state: { contract, accounts, listVotersEvent },
  } = useEth();
  const [storageValue, setStorageValue] = useState(null);

  const getVoter = async (e) => {
    if (e.target.tagName === "INPUT") {
      return;
    }
    let valeur = document.getElementById("getVoter").value;
    if (valeur === "") {
      alert("Please enter a public address to check.");
      return;
    }

    await contract.methods
      .getVoter(valeur)
      .call({ from: accounts[0] })
      .then((results) => {
        results.isRegistered
          ? setStorageValue(
              "Public address : " + valeur + " is registered as voter"
            )
          : setStorageValue("Not registered as voter");
      })
      .catch((err) => alert(err.message));
  };

  const addVoter = async (e) => {
    if (e.target.tagName === "INPUT") {
      return;
    }
    let valeur = document.getElementById("addVoter").value;
    if (valeur === "") {
      alert("Please enter a public address to register.");
      return;
    }
    await contract.methods
      .addVoter(valeur)
      .send({ from: accounts[0] })
      .catch((err) => alert(err));
  };

  const deleteVoter = async (e) => {
    if (e.target.tagName === "INPUT") {
      return;
    }
    let valeur = document.getElementById("deleteVoter").value;
    if (valeur === "") {
      alert("Please enter a public address to register.");
      return;
    }
    await contract.methods
      .deleteVoter(valeur)
      .send({ from: accounts[0] })
      .catch((err) => alert(err.message));
  };

  return (
    <div>
      <details>
        <summary>Add voters</summary>
        <div>
          <p>Allow voter registration by the owner of the contract</p>
          <input type="address" defaultValue="" id="addVoter" size="45" />
          <button onClick={addVoter}>
            Set the address you want to register
          </button>
        </div>
        <br />
        <div>
          <p>Allow voter registration by the owner of the contract</p>
          <input type="address" defaultValue="" id="deleteVoter" size="45" />
          <button onClick={deleteVoter}>
            Set the address you want to register
          </button>
        </div>
        <br />
        <p>Allow user to check if an address is authorzied to vote</p>
        <div>
          <input type="address" defaultValue="" id="getVoter" size="45" />
          <button onClick={getVoter}>Type the address you want to check</button>
          {storageValue && <p>Voter status : </p>}
          <span className="secondary-color">
            <strong>{storageValue}</strong>
          </span>
          <br />
          <br />
        </div>

        <table className="eventTable">
          <thead>
            <tr>
              <th>List of past events related to voters</th>
            </tr>
          </thead>
          <tbody>
            {listVotersEvent.map((item) => (
              <tr key={item.id}>
                <td>Voter Address </td>
                <td>{item.returnValues.voterAddress}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </details>
    </div>
  );
}

export default Voters;
