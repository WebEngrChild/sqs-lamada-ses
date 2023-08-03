import { SES } from 'aws-sdk';
const ses = new SES();

export async function handler(event) {
  for (const record of event.Records) {
    const body = JSON.parse(record.body);
    const email = body.email;
    const name = body.name;

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
      Source: 'your-email@example.com',
    };

    await ses.sendEmail(params).promise();
  }
}