const dotenv = require("dotenv");
const info = require("./info.json");
const nodemailer = require("nodemailer");
dotenv.config();

const {
  convertDataToExcel,
  getConfigMSSQL,
  getDataFromQueries,
  getQuery,
} = require("./utils");

async function executeQueries() {
  const config = getConfigMSSQL();
  try {
    const queriesProms = info.map(async (item) => {
      const queryString = await getQuery(item.queryPath);
      return [item.sheetName, queryString];
    });
    const queriesResult = await Promise.allSettled(queriesProms);
    const queries = queriesResult.map((e) => e.value);
    const dataProms = await getDataFromQueries(config, queries);
    const dataResult = await Promise.allSettled(dataProms);
    const data = dataResult.map((e) => e.value);
    console.log(data);
    await convertDataToExcel(data, "./hoja_sql.xls");
  } catch (e) {
    console.log(e);
  }
}

async function sendEmail() {
  const transport = nodemailer.createTransport({
    host: "smtp-mail.outlook.com",
    secureConnection: false,
    port: 587,
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
    tls: {
      ciphers: "SSLv3",
    },
  });

  const info = await transport.sendMail({
    attachments: {
      filename: "ReporteSemanal.xls",
      path: "./hoja_sql.xls",
    },
    from: `"Rosa Chavez" <${process.env.EMAIL_USER}>`,
    to: ` <${process.env.EMAIL_DEST}> ,<${process.env.EMAIL_USER}>`,
    subject: "Reporte Semanal",
    text: "Buen dia estimado, se le adjunta el archivo de Reporte Semanal. saludos cordiales.",
  });

  console.log("Message sent: %s", info.messageId);

  console.log("Preview URL: %s", nodemailer.getTestMessageUrl(info));
}

async function main() {
  await executeQueries();
  await sendEmail();
  await Promise.resolve().then(() => setTimeout(() => process.exit(0), 5000));
}

main().catch((err) => console.log(err));
