const repository = require('./repository');

const takeOne = () => {
  return repository.read().then((stock) => {
    let currentStockValue = parseInt(stock);
    if (currentStockValue > 0) {
      const stockMinusOne = currentStockValue - 1;
      return repository.save(stockMinusOne).then(true);
    }

    return Promise.resolve(false);
  })
}

const addOne = () => {
  return repository.read().then((stock) => {
    let stockPlusOne = parseInt(stock) + 1;
    return repository.save(stockPlusOne);
  })
}

const currentValue = () => {
  return repository.read();
}

module.exports = {
  takeOne,
  addOne,
  currentValue
}