
# **Adjusted Setup of the SDK Devnet from Scroll**

During the EthGlobal Bangkok hackathon, I tried to do the Scroll SDK Devnet set up on a Windows Subsystem for Linux (Ubuntu). While following the [official guide](https://docs.scroll.io/en/sdk/guides/devnet-deployment/) and [video tutorial](https://www.youtube.com/watch?v=r7MMAg0Menw), I encountered several issues that required adjustments. Below is a summary of the challenges and their solutions:

---

### **Issue 1: Configuration Adjustment**

- **Problem:** After running `make bootstrap`, I encountered errors related to Blockscout. Continuing with `make install`, the process stalled, and errors occurred.
- **Solution:** The Minikube configuration was adjusted. Instead of using:
    ```bash
    minikube config set cpus 8
    minikube config set memory 8192
    ```
    or the values used in the the video tutorial:
    ```bash
    minikube config set cpus 8
    minikube config set memory 6592
    ```
    I used:
    ```bash
    minikube config set cpus 8
    minikube config set memory 7592
    ```
    This resolved most issues and allowed the setup to proceed.

---

### **Issue 2: Blockscout Errors**

![Missing Blockscout ingresses](./images/code_blockscout_error.png)

- **Problem:** 
The `blockscout-blockscout-84554fb4dd-5cklw` pod remained in a `Pending` state. Additionally, `kubectl get ingress` did not list the expected `blockscout-backend-ingress`.
- **Solution:** This issue was left unresolved as it did not block further progress. Running `scrollsdk test ingress` confirmed Blockscout was unreachable, but the setup could still continue.

---

### **Issue 3: Accessing the Frontend**
- **Problem:** Opening `http://frontends.scrollsdk` in the host browser resulted in a blank page.
- **Solution:** Installing browsers within the Ubuntu subsystem allowed me to access the frontend. Here’s how I set them up:

#### **Installing Chrome**
1. Create a directory for the installer:
   ```bash
   mkdir chrome
   cd chrome/
   ```
2. Download and install Chrome:
   ```bash
   wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
   sudo dpkg -i google-chrome-stable_current_amd64.deb
   sudo apt-get install -f # Fix missing dependencies
   google-chrome-stable
   ```

#### **Installing Firefox**
- I followed the "Install Firefox .deb package for Debian-based distributions" section from [Mozilla's guide](https://support.mozilla.org/en-US/kb/install-firefox-linux).

Both browsers worked when launched from the subsystem, allowing access to the Scroll frontend.

---

### **Issue 4: Connecting Scroll SDK Chain RPC to MetaMask**

![MetaMask error](./images/metamask_error.png)

- **Problem:** Adding the Scroll SDK Chain to MetaMask in Chrome or Firefox on the host browser was not possible, as MetaMask did not allow me to save the network.
- **Solution:** Installing MetaMask in the Ubuntu subsystem browsers (Chrome and Firefox) resolved this issue. I was able to add the Scroll SDK Chain using the following details:
  - **Network Name:** Scroll SDK Chain  
  - **New RPC URL:** `http://l2-rpc.scrollsdk`  
  - **Chain ID:** `221122`  
  - **Currency Symbol:** `ETH`
  - **Block Explorer URL:** `http://blockscout.scrollsdk`

This allowed me to interact with the Scroll SDK via MetaMask.


# **Simple Voting App**

After completing the setup and installation of the Scroll SDK Devnet, you can use the [Remix IDE](https://remix.ethereum.org) to easily deploy and interact with a smart contract on your locally hosted rollup. 

The code from the repository can either:
1. Be downloaded as a ZIP file and uploaded directly into the Remix IDE, or
2. Copied and pasted from the example provided below into a new contract file in the standard Remix IDE setup.

---

## **NobleVoting.sol**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract NobleVoting {

    // Counters for the votes (now just 0, 1, and 2 to keep it simple)
    uint256[3] public votes;

    // A mapping to check or store addresses that have already voted
    mapping(address => bool) public hasVoted;

    // A mapping to store the current vote choice of each address
    mapping(address => uint256) public currentChoice;

    function vote(uint256 _userChoice) public {
        // Ensure the input is either 0, 1, or 2
        require(_userChoice < 3, "Invalid choice. Please vote for 0, 1, or 2.");

        // Check if the user has already voted
        if (hasVoted[msg.sender]) {
            // Decrease the vote count for the previous choice
            uint256 previousChoice = currentChoice[msg.sender];
            votes[previousChoice]--;
        } else {
            // Mark the user as having voted
            hasVoted[msg.sender] = true;
        }        
        
        // Record the new vote choice
        currentChoice[msg.sender] = _userChoice;

        // Increment the vote count for the chosen number
        votes[_userChoice]++;
    }

    function getVotesForNumber(uint256 _numberOfChoice) public view returns (uint256) {
        // Ensure the input is valid
        require(_numberOfChoice < 3, "Invalid choice. Please query for 0, 1, or 2.");
        return votes[_numberOfChoice];
    }

    function getAllVotes() public view returns (uint256[3] memory) {
        return votes;
    }
}
```

---

## **Code Explanation**

The `NobleVoting` contract provides a simple and user-friendly way to vote on one of three options (`0`, `1`, or `2`). Users can also change their vote if they change their preference.

---

### **How It Works**

1. **Voting:**
   - Users call the `vote(uint256 _userChoice)` function with their choice (`0`, `1`, or `2`).
   - If the user has already voted:
     - The vote count for their previous choice is decremented.
     - The user's new choice is recorded.
   - If this is the user's first vote:
     - Their address is marked as having voted.
     - Their choice is recorded, and the vote count for that choice is incremented.

2. **Viewing Votes:**
   - `getVotesForNumber(uint256 _numberOfChoice)`:
     - Returns the total number of votes for a specific choice (e.g., `0`, `1`, or `2`).
   - `getAllVotes()`:
     - Provides the total number of votes for all three choices as an array.

3. **Data Storage:**
   - **`hasVoted`:** A mapping to track whether an address has already voted.
   - **`currentChoice`:** A mapping to store the current vote of each user.
   - **`votes`:** An array that tracks the total number of votes for each choice (`0`, `1`, and `2`).

---

### **Key Features**

- **Counters for Votes:** Tracks votes for `0`, `1`, and `2` in the `votes` array.
- **Update Votes:** Users can update their vote if they change their mind; the old vote is decremented, and the new one is recorded.
- **Input Validation:** Ensures only valid choices (`0`, `1`, or `2`) can be voted on.
- **Transparency:** Anyone can query the current vote counts using `getVotesForNumber` or `getAllVotes`.

---

### **Why Use This Contract?**
This contract demonstrates the basic functionality of blockchain-based voting:
- **Immutable Records:** Each vote is securely stored on the blockchain.
- **Fairness:** One vote per user, with the option to update.
- **Transparency:** Anyone can view the results in real time.

Deploying this contract on the Scroll SDK Devnet provides a practical use case to explore voting systems and interact with blockchain technology.

