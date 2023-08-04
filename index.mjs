const AWS = require('aws-sdk');
const ses = new AWS.SES();

export async function handler(event) {
  for (const record of event.Records) {
    try {
      const body = JSON.parse(record.body);
      const email = body.email;
      const name = body.name;

      if (!email || !name) {
        console.error('Email or name missing from the record:', record);
        continue;
      }

      const params = {
        Destination: {
          ToAddresses: [email],
        },
        Message: {
          Body: {
            Text: { Data: `${name}様への本文` },
          },
          Subject: { Data: `${name}様へのタイトル` },
        },
        Source: 'factor_9mmplusfact@yahoo.co.jp',
      };

      await ses.sendEmail(params).promise();
      console.log(`Email sent successfully to ${email}`);
    } catch (error) {
      console.error('Error processing record:', record, 'Error:', error);
    }
  }
}
