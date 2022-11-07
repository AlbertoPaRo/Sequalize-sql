const ExcelJS = require("exceljs");

async function convertHandleDataToExcel(data, filename) {
  try {
    const workbook = new ExcelJS.Workbook();
    data.forEach((element) => {
      const sheetName = element[0];
      const values = element[1].recordset;
      const columnsHeaders = element[2];
      const sheet = workbook.addWorksheet(sheetName);
      const cols = Object.keys(values[0]).map((prop) => {
        return {
          header: prop,
          key: prop,
          width: 25,
        };
      });
      sheet.columns = cols;
      sheet.addRows(values);
      const cellValue = getCellByName(sheet, columnsHeaders);
      levelPercentage(sheet, cellValue);
    });
    await workbook.xlsx.writeFile(fileName);
    return true;
  } catch (err) {
    throw new Error(err);
  }
}
function getCellByName(worksheet, headers) {
  const result = [];
  const row = worksheet.getRow(1);
  for (let i = 1; i < row.values.length; i++) {
    const cell = row.getCell(i);
    result.push({ ...cell });
  }
  return result.filter((cell) => headers.includes(cell._column._header));
}

function levelPercentage(worksheet, cells) {
  const getColor = (value) => {
    if (value >= 100) return "#3ed140";
    if (value < 100 && value >= 79) return "#faed15";
    return "#e53004";
  };

  cells.forEach((item) => {
    const col = worksheet.getColumn(item._column._number);
    col.eachCell(function (cell, rowNumber) {
      const model = cell._value.model;
      const value = model.value;
      const color = getColor(value);
      const addr = cell._address;
      const borderColor = "#000000".slice(1);

      const borderType = { style: "thin", color: { argb: borderColor } };

      if (model.value !== item._column._header) {
        worksheet.getCell(addr).fill = {
          type: "pattern",
          pattern: "darkVertical",
          fgColor: { argb: color.slice(1) },
        };

        worksheet.getCell(addr).border = {
          top: borderType,
          left: borderType,
          bottom: borderType,
          right: borderType,
        };
      }
    });
  });
  return true;
}
module.exports = { convertHandleDataToExcel };
