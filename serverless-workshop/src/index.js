const ERROR_KEY = "error";

exports.handler = async (event) => {

  console.info(JSON.stringify(event));

  event.Records.forEach(record => {
    const body = JSON.parse(record['body']);

    if (body['detail'].hasOwnProperty(ERROR_KEY) && body['detail'][ERROR_KEY]) {
      const errorMessage = "Exception has occurred while processing an order";
      console.error(errorMessage);
      throw new Error(errorMessage);
    }
  });

  const response = {
    statusCode: 200,
    body: JSON.stringify('Hello from Lambda!')
  };
  return response;
};
