const ExcelJS = require("exceljs");

class ExcelHandle {
  constructor() {}

  addWorkSheet({ workbook, nameSheet }) {
    if (!workbook) throw new Error("workbook not exists");
    const sheet = workbook.addWorksheet(nameSheet);
    return sheet;
  }

  createWorkBook() {
    const workbook = new ExcelJS.Workbook();
    return workbook;
  }
}

module.exports = {
  ExcelHandle,
};
