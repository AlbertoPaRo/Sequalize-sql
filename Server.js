const sql = require("mssql");
const fs = require("node:fs");
const XLSX = require("xlsx");

async function executeQueries(queries = []) {
  // config for your database
  const config = {
    user: "prueba1",
    password: "12345",
    server: "127.0.0.1",
    database: "inventario",
    options: {
      encrypt: false,
      trustServerCertificate: true,
    },
  };

  const getQueries = () => {
    return new Promise((resolve, reject) => {
      let results;
      sql.connect(config, (err) => {
        if (err) reject(err);
        const request = new sql.Request();
        results = queries.map((queryString) => {
          return new Promise((resolve, reject) => {
            request.query(queryString, (err, data) => {
              if (err) reject(err);

              resolve(data);
            });
          });
        });
        resolve(results);
      });
    });
  };
  const queriesProms = await getQueries();
  const data = await Promise.allSettled(queriesProms);
  const dataExcelProms = data
    .filter((e) => e?.value?.recordset?.length)
    .map(async (e, i) => {
      const nameExcel = (num, flag = true) =>
        flag ? `hoja_${num}_${+new Date()}.xls` : `./${num}.xls`;
      return convertDataToExcel(e.value.recordset, nameExcel(i));
    });
  await Promise.allSettled(dataExcelProms);
  const dataJSON = JSON.stringify(data.map((e) => e.value));
  const jsonName = `results_${+new Date()}.json`;
  fs.writeFile(jsonName, dataJSON, (err) => {
    if (err) throw err;
    console.log("The file has been saved!");
  });
}

function convertDataToExcel(data, pathFileName) {
  return new Promise((resolve, reject) => {
    try {
      const sheetName = "Test";
      const worksheet = XLSX.utils.json_to_sheet(data);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, sheetName);
      XLSX.writeFile(workbook, pathFileName);
      resolve(true);
    } catch (err) {
      reject(err);
    }
  });
}

function readFiles(dirname, onFileContent, onError) {
  fs.readdir(dirname, function (err, filenames) {
    if (err) {
      onError(err);
      return;
    }
    filenames.forEach(function (filename) {
      fs.readFile(dirname + filename, "utf-8", function (err, content) {
        if (err) {
          onError(err);
          return;
        }
        onFileContent(filename, content);
      });
    });
  });
}

async function main() {
  const queries = ["Select 42"];

  readFiles(
    "queries/",
    function (filename, content) {
      queries.push(content);
    },
    function (err) {
      throw err;
    }
  );
  await executeQueries(queries);
  await Promise.resolve().then(() => setTimeout(() => process.exit(0), 2000));
}

main();
