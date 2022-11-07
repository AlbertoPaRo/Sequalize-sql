const ExcelJS = require("exceljs");

class ExcelHandle {
  constructor() {}

  addWorkSheet({ workbook, sheetName }) {
    if (!workbook) throw new Error("workbook not exists");
    const sheet = workbook.addWorksheet(sheetName);
    return { sheet, workbook };
  }

  createWorkBook() {
    const workbook = new ExcelJS.Workbook();
    return workbook;
  }

  addRows(sheet, data) {
    const cols = Object.keys(data[0]).map((prop) => {
      return {
        header: prop,
        key: prop,
        width: 45,
      };
    });
    sheet.columns = cols;
    sheet.addRows(data);
    return true;
  }

  async writeFile(workbook, fileName) {
    await workbook.xlsx.writeFile(fileName);
    return true;
  }

  async handleData(sheetName, data, fileName) {
    const wb = new ExcelJS.Workbook();
    const sheet = wb.addWorksheet(sheetName);
    const cols = Object.keys(data[0]).map((prop) => {
      return {
        header: prop,
        key: prop,
        width: prop.length,
      };
    });
    sheet.columns = cols;
    sheet.addRows(data);
    await wb.xlsx.writeFile(fileName);
    return wb;
  }

  //   getCellByName(worksheet, name) {
  //     var match;
  //     worksheet.eachRow(function (row) {
  //         row.eachCell(function (cell) {
  //             for (var i = 0; i < cell.names.length; i++) {
  //                 if (cell.names[i] === name) {
  //                     match = cell;
  //                     break;
  //                 }
  //             }
  //         });
  //     });
  //     return match;
  // }

  getCellByName(worksheet, headers) {
    const result = [];
    const row = worksheet.getRow(1);
    for (let i = 1; i < row.values.length; i++) {
      const cell = row.getCell(i);
      result.push({ ...cell });
    }
    return result.filter((cell) => headers.includes(cell._column._header));
  }

  getHeaders(worksheet, index) {
    const result = [];

    const row = worksheet.getRow(index);

    if (row === null || !row.values || !row.values.length) return [];

    for (let i = 1; i < row.values.length; i++) {
      const cell = row.getCell(i);
      result.push(cell.text);
    }
    return result;
  }
}

module.exports = {
  ExcelHandle,
};
