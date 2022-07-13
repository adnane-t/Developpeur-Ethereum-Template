function Tree() {
  return (
    <code>
      {`.\n`}
      {`├── client`}
      <span className="primary-color">
        {`   # React project (create-react-app)\n`}
      </span>
      {`├    └── src`}
      <span className="third-color">
        {`   # React project (create-react-app)\n`}
      </span>
      {`├         ├── componenents`}
      <span className="third-color">{`   # React components\n`}</span>
      {`├         ├── contexts/ETHContext`}
      <span className="third-color">
        {`   # React context and web3 initiator\n`}
      </span>
      {`├         └── contract`}
      <span className="secondary-color">{`   # Contract definition\n`}</span>
      {`└── truffle`}
      <span className="primary-color">{`  # Truffle project`}</span>
    </code>
  );
}

export default Tree;
