const { ExcelHandle } = require("../src/ExcelHandle");
const { Workbook } = require("exceljs");

describe("Excel Handle suite test", () => {
  it("create worbook", () => {
    const excelHandle = new ExcelHandle();

    expect(excelHandle.createWorkBook()).toBeInstanceOf(Workbook);
  });
  it("create worksheet", () => {
    const excelHandle = new ExcelHandle();
    const wb = excelHandle.createWorkBook();
    const name = "My sheet";

    expect(
      excelHandle.addWorkSheet({ workbook: wb, nameSheet: name })
    ).toBeInstanceOf(Object);
  });
  it("id worksheet", () => {
    const excelHandle = new ExcelHandle();
    const sheet1 = "My Sheet 1";
    const wb1 = excelHandle.createWorkBook();
    const sheet2 = "My sheet 2";
    const sheet3 = "My sheet C";

    expect(wb1).toBeInstanceOf(Workbook);
    expect(
      excelHandle.addWorkSheet({ workbook: wb1, nameSheet: sheet1 }).id
    ).toBe(1);
    expect(
      excelHandle.addWorkSheet({ workbook: wb1, nameSheet: sheet2 }).id
    ).toBe(2);
    expect(
      excelHandle.addWorkSheet({ workbook: wb1, nameSheet: sheet3 }).id
    ).toBe(3);
  });

  it("fail add workSheet", () => {
    const excelHandle = new ExcelHandle();
    const sheet1 = "My Sheet 1";
    const wb = excelHandle.createWorkBook();
    expect(wb).toBeInstanceOf(Workbook);
    expect(async () =>
      excelHandle.addWorkSheet({ nameSheet: sheet1 })
    ).rejects.toThrowError(new Error("workbook not exists"));
  });
});
