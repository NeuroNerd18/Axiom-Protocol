// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Ensure this matches your hardhat.config.cjs Solidity version

interface IJob {
    // --- Enums ---
    // Must exactly match the enum defined in `Job.sol`.
    enum JobStatus { Pending, Fulfilled, Failed }

    // --- Structs ---
    // Must exactly match the struct defined in `Job.sol`.
    struct JobDetails {
        uint256 agentId;
        address user;
        uint256 paymentAmount;
        string inputData;
        string outputData;
        JobStatus status;
        bytes32 requestId;
        bytes rawResponse;
        bytes rawError;
    }

    // --- Events ---
    // Must exactly match the events defined in `Job.sol`, including `indexed` parameters (max 3 per event).
    event JobCreated(
        uint256 indexed jobId,
        uint256 agentId, // Not indexed to adhere to 3 indexed args limit
        address indexed user,
        uint256 paymentAmount,
        string inputData,
        bytes32 indexed requestId
    );
    event JobFulfilled(uint256 indexed jobId, string outputData, bytes32 indexed requestId);
    event JobFailed(uint256 indexed jobId, string reason, bytes32 indexed requestId);
    event FunctionsRouterUpdated(address indexed oldRouter, address indexed newRouter);
    event FunctionsSubscriptionUpdated(uint64 indexed oldSubscriptionId, uint64 indexed newSubscriptionId);
    event CallbackGasLimitUpdated(uint32 oldLimit, uint32 newLimit);


    // --- Functions ---
    // Public/external functions from `Job.sol`.
    // The `createJob` function, callable by users.
    function createJob(
        uint256 _agentId,
        string memory _inputData,
        string calldata _functionsSourceCode,
        bytes calldata _functionsSecrets,
        string[] calldata _functionsArgs
    ) external payable returns (uint256);

    // The `fulfill` callback function, called by Chainlink Functions.
    // The signature must match what `FunctionsClient` expects. It's `external` from the interface's perspective.
    function fulfill(bytes32 requestId, bytes memory response, bytes memory err) external;

    // View functions for querying contract state.
    // Automatically generated by public mappings in `Job.sol`.
    function jobs(bytes32) external view returns (
        uint256 agentId,
        address user,
        uint256 paymentAmount,
        string memory inputData,
        string memory outputData,
        JobStatus status,
        bytes32 requestId,
        bytes memory rawResponse,
        bytes memory rawError
    );
    function jobIdToRequestId(uint256) external view returns (bytes32);
    function nextJobId() external view returns (uint256);

    // Administrative view functions for Chainlink settings.
    function s_functionsRouter() external view returns (address);
    function s_functionsSubscriptionId() external view returns (uint64);
    function s_callbackGasLimit() external view returns (uint32);

    // Administrative functions, callable by the contract owner.
    function setFunctionsRouter(address _router) external;
    function setFunctionsSubscriptionId(uint64 _subscriptionId) external;
    function setCallbackGasLimit(uint32 _newLimit) external;

    // Inherited from ConfirmedOwner (Chainlink's access control contract).
    // These functions define the contract's ownership interface.
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function acceptOwnership() external; // ConfirmedOwner includes an `acceptOwnership` step for transfer
}