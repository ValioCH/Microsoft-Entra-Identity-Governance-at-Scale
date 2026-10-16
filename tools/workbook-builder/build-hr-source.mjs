import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const projectRoot = path.resolve(import.meta.dirname, "..", "..");
const outputDir = path.join(projectRoot, "outputs", "identity-governance");
await fs.mkdir(outputDir, { recursive: true });

const workbook = Workbook.create();
const overview = workbook.worksheets.add("Overview");
const employees = workbook.worksheets.add("Employees");
const mapping = workbook.worksheets.add("IAM Mapping");
const audit = workbook.worksheets.add("Audit");
const reference = workbook.worksheets.add("Reference");

const navy = "#17365D";
const blue = "#2F75B5";
const lightBlue = "#D9EAF7";
const amber = "#FFF2CC";
const lightGray = "#F2F2F2";
const darkText = "#1F2937";
const redFill = "#FCE8E6";
const redText = "#B91C1C";
const greenFill = "#E2F0D9";
const greenText = "#2E7D32";
const fontFamily = "Arial";

for (const sheet of [overview, employees, mapping, audit, reference]) {
  sheet.showGridLines = false;
}

const employeeRows = [
  ["LAB-1000", "Alexander", "Novak", "alexander.novak", "Executive", "Chief Operating Officer", "Employee", "", "Sofia", "BG", "Create", "Active", new Date("2026-09-01"), null, "CC-100", "HR-LAB", 1],
  ["LAB-1100", "Maya", "Ivanova", "maya.ivanova", "HR", "HR Director", "Employee", "LAB-1000", "Sofia", "BG", "Create", "Active", new Date("2026-09-01"), null, "CC-110", "HR-LAB", 1],
  ["LAB-1101", "Nikolai", "Petrov", "nikolai.petrov", "HR", "HR Specialist", "Employee", "LAB-1100", "Varna", "BG", "Create", "Active", new Date("2026-09-07"), null, "CC-110", "HR-LAB", 1],
  ["LAB-1200", "Elena", "Marinova", "elena.marinova", "Finance", "Finance Director", "Employee", "LAB-1000", "Sofia", "BG", "Create", "Active", new Date("2026-09-01"), null, "CC-120", "HR-LAB", 1],
  ["LAB-1201", "Adele", "Vance", "adele.vance", "Finance", "Finance Analyst", "Employee", "LAB-1200", "Sofia", "BG", "Update", "Active", new Date("2026-09-01"), null, "CC-120", "HR-LAB", 2],
  ["LAB-1202", "Daniel", "Popescu", "daniel.popescu", "Finance", "Accountant", "Employee", "LAB-1200", "Bucharest", "RO", "Create", "Active", new Date("2026-09-14"), null, "CC-120", "HR-LAB", 1],
  ["LAB-1300", "Stefan", "Dimitrov", "stefan.dimitrov", "IT", "IT Director", "Employee", "LAB-1000", "Sofia", "BG", "Create", "Active", new Date("2026-09-01"), null, "CC-130", "HR-LAB", 1],
  ["LAB-1301", "Chris", "Green", "chris.green", "IT", "Identity Support Analyst", "Employee", "LAB-1300", "Varna", "BG", "Update", "Active", new Date("2026-09-01"), null, "CC-130", "HR-LAB", 2],
  ["LAB-1302", "Irina", "Kovacs", "irina.kovacs", "IT", "Security Engineer", "Employee", "LAB-1300", "Bucharest", "RO", "Create", "Active", new Date("2026-09-08"), null, "CC-130", "HR-LAB", 1],
  ["LAB-1303", "Georgi", "Stoyanov", "georgi.stoyanov", "IT", "Service Desk Analyst", "Employee", "LAB-1300", "Varna", "BG", "Create", "Active", new Date("2026-09-21"), null, "CC-130", "HR-LAB", 1],
  ["LAB-1400", "Sara", "Muller", "sara.muller", "Sales", "Sales Director", "Employee", "LAB-1000", "Sofia", "BG", "Create", "Active", new Date("2026-09-01"), null, "CC-140", "HR-LAB", 1],
  ["LAB-1401", "Petar", "Kolev", "petar.kolev", "Sales", "Sales Executive", "Employee", "LAB-1400", "Varna", "BG", "Create", "Active", new Date("2026-09-15"), null, "CC-140", "HR-LAB", 1],
  ["LAB-1402", "Ana", "Ionescu", "ana.ionescu", "Sales", "Sales Executive", "Employee", "LAB-1400", "Bucharest", "RO", "Create", "Active", new Date("2026-09-15"), null, "CC-140", "HR-LAB", 1],
  ["LAB-1500", "Viktor", "Georgiev", "viktor.georgiev", "Operations", "Operations Manager", "Employee", "LAB-1000", "Sofia", "BG", "Create", "Active", new Date("2026-09-01"), null, "CC-150", "HR-LAB", 1],
  ["LAB-1501", "Maria", "Radu", "maria.radu", "Operations", "Operations Specialist", "Employee", "LAB-1500", "Bucharest", "RO", "Create", "Active", new Date("2026-09-18"), null, "CC-150", "HR-LAB", 1],
  ["LAB-1502", "Kalin", "Todorov", "kalin.todorov", "Operations", "Warehouse Coordinator", "Employee", "LAB-1500", "Varna", "BG", "Create", "Active", new Date("2026-09-18"), null, "CC-150", "HR-LAB", 1],
  ["LAB-1600", "Lucas", "Martin", "lucas.martin", "IT", "Application Developer", "Contractor", "LAB-1300", "Sofia", "BG", "Create", "Active", new Date("2026-09-20"), new Date("2026-12-20"), "CC-130", "HR-LAB", 1],
  ["LAB-1601", "Eva", "Horvat", "eva.horvat", "Finance", "External Auditor", "Contractor", "LAB-1200", "Sofia", "BG", "Create", "Active", new Date("2026-09-20"), new Date("2026-11-30"), "CC-120", "HR-LAB", 1],
  ["LAB-1700", "Martin", "Iliev", "martin.iliev", "IT", "Junior Identity Analyst", "Employee", "LAB-1300", "Varna", "BG", "Create", "PreHire", new Date("2026-09-28"), null, "CC-130", "HR-LAB", 1],
  ["LAB-1800", "Olivia", "Brown", "olivia.brown", "Sales", "Sales Executive", "Employee", "LAB-1400", "Sofia", "BG", "Disable", "LeaveScheduled", new Date("2026-02-01"), new Date("2026-09-30"), "CC-140", "HR-LAB", 4],
];

// Overview
overview.getRange("A2:H2").merge();
overview.getRange("A2").values = [["Enterprise identity lifecycle source"]];
overview.getRange("A2").format.font = { name: fontFamily, size: 16, bold: true, color: navy };
overview.getRange("A3:H3").merge();
overview.getRange("A3").values = [["Synthetic HR input for validation, change planning and governed Microsoft Entra provisioning"]];
overview.getRange("A3").format.font = { name: fontFamily, size: 10, italic: true, color: "#5B6573" };
overview.getRange("A5:B5").values = [["Metric", "Value"]];
overview.getRange("A6:A10").values = [["HR records"], ["Create actions"], ["Update actions"], ["Disable actions"], ["Validation failures"]];
overview.getRange("B6:B10").formulas = [
  ["=COUNTA(Employees!$A$6:$A$25)"],
  ["=COUNTIF(Employees!$K$6:$K$25,\"Create\")"],
  ["=COUNTIF(Employees!$K$6:$K$25,\"Update\")"],
  ["=COUNTIF(Employees!$K$6:$K$25,\"Disable\")"],
  ["=COUNTIF(Audit!$H$6:$H$25,\"FAIL\")"],
];
overview.getRange("D5:H5").merge();
overview.getRange("D5").values = [["Pipeline stages"]];
overview.getRange("D6:H11").values = [
  ["1", "Validate", "Schema, required values, unique IDs and manager references", "Offline", "Blocking"],
  ["2", "Plan", "Compare desired HR state with current Entra state", "Read-only Graph", "Blocking"],
  ["3", "Approve", "Human reviews change counts, exceptions and rollback", "Approval gate", "Blocking"],
  ["4", "Apply", "Create, update or disable only approved identities", "Graph write", "Controlled"],
  ["5", "Verify", "Re-query Entra and compare observed with desired state", "Read-only Graph", "Blocking"],
  ["6", "Evidence", "Record sanitized results and rollback outcome", "Repository", "Required"],
];
overview.getRange("A13:H13").merge();
overview.getRange("A13").values = [["HR owns workforce facts. IAM owns the rules that translate those facts into groups, licenses and access."]];
overview.getRange("A13").format = { fill: lightBlue, font: { name: fontFamily, bold: true, color: navy }, wrapText: true };
overview.getRange("A5:B5").format = { fill: navy, font: { name: fontFamily, bold: true, color: "#FFFFFF" }, horizontalAlignment: "center" };
overview.getRange("D5:H5").format = { fill: navy, font: { name: fontFamily, bold: true, color: "#FFFFFF" }, horizontalAlignment: "center" };
overview.getRange("A6:B10").format.font = { name: fontFamily, size: 10, color: darkText };
overview.getRange("D6:H11").format.font = { name: fontFamily, size: 10, color: darkText };
overview.getRange("A5:B10").format.borders = { preset: "outside", style: "thin", color: "#B4C6E7" };
overview.getRange("D5:H11").format.borders = { preset: "outside", style: "thin", color: "#B4C6E7" };
overview.getRange("A:A").format.columnWidth = 25;
overview.getRange("B:B").format.columnWidth = 12;
overview.getRange("C:C").format.columnWidth = 3;
overview.getRange("D:D").format.columnWidth = 7;
overview.getRange("E:E").format.columnWidth = 15;
overview.getRange("F:F").format.columnWidth = 52;
overview.getRange("G:G").format.columnWidth = 18;
overview.getRange("H:H").format.columnWidth = 14;
overview.getRange("A2:H13").format.verticalAlignment = "center";

// Employees
employees.getRange("A2:Q2").merge();
employees.getRange("A2").values = [["HR workforce source"]];
employees.getRange("A2").format.font = { name: fontFamily, size: 14, bold: true, color: navy };
employees.getRange("A3:Q3").merge();
employees.getRange("A3").values = [["Editable synthetic records. Groups, licenses and roles are intentionally excluded from the HR-owned schema."]];
employees.getRange("A3").format.font = { name: fontFamily, size: 10, italic: true, color: "#5B6573" };
const employeeHeaders = [["EmployeeId", "GivenName", "Surname", "UserAlias", "Department", "JobTitle", "EmployeeType", "ManagerEmployeeId", "Location", "CountryCode", "LifecycleAction", "EmploymentStatus", "StartDate", "EndDate", "CostCenter", "SourceSystem", "RecordVersion"]];
employees.getRange("A5:Q5").values = employeeHeaders;
employees.getRange("A6:Q25").values = employeeRows;
employees.getRange("M6:N25").setNumberFormat("yyyy-mm-dd");
employees.getRange("Q6:Q25").setNumberFormat("0");
employees.getRange("A5:Q25").format.font = { name: fontFamily, size: 10, color: darkText };
employees.getRange("A5:Q5").format = { fill: navy, font: { name: fontFamily, size: 10, bold: true, color: "#FFFFFF" }, horizontalAlignment: "center", verticalAlignment: "center", wrapText: true };
employees.getRange("A6:Q25").format.fill = amber;
employees.getRange("A5:Q25").format.verticalAlignment = "center";
employees.tables.add("A5:Q25", true, "HrEmployeesTable").style = "TableStyleMedium2";
employees.freezePanes.freezeRows(5);
employees.freezePanes.freezeColumns(4);
employees.getRange("A:A").format.columnWidth = 13;
employees.getRange("B:C").format.columnWidth = 15;
employees.getRange("D:D").format.columnWidth = 22;
employees.getRange("E:E").format.columnWidth = 14;
employees.getRange("F:F").format.columnWidth = 28;
employees.getRange("G:G").format.columnWidth = 14;
employees.getRange("H:H").format.columnWidth = 18;
employees.getRange("I:I").format.columnWidth = 13;
employees.getRange("J:J").format.columnWidth = 12;
employees.getRange("K:L").format.columnWidth = 16;
employees.getRange("M:N").format.columnWidth = 13;
employees.getRange("O:P").format.columnWidth = 14;
employees.getRange("Q:Q").format.columnWidth = 13;

// IAM Mapping
mapping.getRange("A2:F2").merge();
mapping.getRange("A2").values = [["IAM policy mapping"]];
mapping.getRange("A2").format.font = { name: fontFamily, size: 14, bold: true, color: navy };
mapping.getRange("A3:F3").merge();
mapping.getRange("A3").values = [["IAM-owned rules convert authoritative HR attributes into access. HR does not assign these controls directly."]];
mapping.getRange("A3").format.font = { name: fontFamily, size: 10, italic: true, color: "#5B6573" };
mapping.getRange("A5:F5").values = [["Department", "Dynamic group", "License profile", "Access package", "Review owner", "Rule expression"]];
mapping.getRange("A6:F11").values = [
  ["Executive", "SG-DYN-Dept-Executive", "E5-Standard", "Executive baseline", "Identity Governance", 'user.department -eq "Executive"'],
  ["HR", "SG-DYN-Dept-HR", "E5-Standard", "HR baseline", "HR Director", 'user.department -eq "HR"'],
  ["Finance", "SG-DYN-Dept-Finance", "E5-Standard", "Finance baseline", "Finance Director", 'user.department -eq "Finance"'],
  ["IT", "SG-DYN-Dept-IT", "E5-Standard", "IT baseline", "IT Director", 'user.department -eq "IT"'],
  ["Sales", "SG-DYN-Dept-Sales", "E5-Standard", "Sales baseline", "Sales Director", 'user.department -eq "Sales"'],
  ["Operations", "SG-DYN-Dept-Operations", "E5-Standard", "Operations baseline", "Operations Manager", 'user.department -eq "Operations"'],
];
mapping.getRange("A14:F14").values = [["Employee type", "Dynamic group", "License override", "Access package", "Review cadence", "Rule expression"]];
mapping.getRange("A15:F16").values = [
  ["Employee", "SG-DYN-Worker-Employees", "None", "Employee baseline", "Annual", 'user.employeeType -eq "Employee"'],
  ["Contractor", "SG-DYN-Worker-Contractors", "Limited", "Contractor baseline", "Quarterly", 'user.employeeType -eq "Contractor"'],
];
for (const headerRange of ["A5:F5", "A14:F14"]) {
  mapping.getRange(headerRange).format = { fill: navy, font: { name: fontFamily, size: 10, bold: true, color: "#FFFFFF" }, horizontalAlignment: "center", wrapText: true };
}
mapping.getRange("A6:F11").format.font = { name: fontFamily, size: 10, color: darkText };
mapping.getRange("A15:F16").format.font = { name: fontFamily, size: 10, color: darkText };
mapping.tables.add("A5:F11", true, "DepartmentAccessMap").style = "TableStyleMedium2";
mapping.tables.add("A14:F16", true, "WorkerTypeAccessMap").style = "TableStyleMedium2";
mapping.getRange("A:A").format.columnWidth = 16;
mapping.getRange("B:B").format.columnWidth = 30;
mapping.getRange("C:C").format.columnWidth = 18;
mapping.getRange("D:D").format.columnWidth = 24;
mapping.getRange("E:E").format.columnWidth = 22;
mapping.getRange("F:F").format.columnWidth = 42;

// Reference
reference.getRange("A2:H2").merge();
reference.getRange("A2").values = [["Controlled values"]];
reference.getRange("A2").format.font = { name: fontFamily, size: 14, bold: true, color: navy };
reference.getRange("A4:H4").values = [["Departments", "Employee types", "Lifecycle actions", "Employment statuses", "Locations", "Country codes", "Source systems", "Validation meaning"]];
reference.getRange("A5:A10").values = [["Executive"], ["HR"], ["Finance"], ["IT"], ["Sales"], ["Operations"]];
reference.getRange("B5:B6").values = [["Employee"], ["Contractor"]];
reference.getRange("C5:C7").values = [["Create"], ["Update"], ["Disable"]];
reference.getRange("D5:D7").values = [["Active"], ["PreHire"], ["LeaveScheduled"]];
reference.getRange("E5:E7").values = [["Sofia"], ["Varna"], ["Bucharest"]];
reference.getRange("F5:F6").values = [["BG"], ["RO"]];
reference.getRange("G5").values = [["HR-LAB"]];
reference.getRange("H5:H7").values = [["PASS: record can enter planning"], ["FAIL: pipeline must stop for the record"], ["Warnings require explicit approval before apply"]];
reference.getRange("A4:H4").format = { fill: navy, font: { name: fontFamily, size: 10, bold: true, color: "#FFFFFF" }, horizontalAlignment: "center", wrapText: true };
reference.getRange("A5:H10").format.font = { name: fontFamily, size: 10, color: darkText };
reference.getRange("A:A").format.columnWidth = 18;
reference.getRange("B:G").format.columnWidth = 18;
reference.getRange("H:H").format.columnWidth = 42;

// Input validation rules
employees.getRange("E6:E205").dataValidation = { rule: { type: "list", formula1: "Reference!$A$5:$A$10" } };
employees.getRange("G6:G205").dataValidation = { rule: { type: "list", formula1: "Reference!$B$5:$B$6" } };
employees.getRange("I6:I205").dataValidation = { rule: { type: "list", formula1: "Reference!$E$5:$E$7" } };
employees.getRange("J6:J205").dataValidation = { rule: { type: "list", formula1: "Reference!$F$5:$F$6" } };
employees.getRange("K6:K205").dataValidation = { rule: { type: "list", formula1: "Reference!$C$5:$C$7" } };
employees.getRange("L6:L205").dataValidation = { rule: { type: "list", formula1: "Reference!$D$5:$D$7" } };
employees.getRange("P6:P205").dataValidation = { rule: { type: "list", formula1: "Reference!$G$5:$G$5" } };

// Audit
audit.getRange("A2:H2").merge();
audit.getRange("A2").values = [["Source validation"]];
audit.getRange("A2").format.font = { name: fontFamily, size: 14, bold: true, color: navy };
audit.getRange("A3:H3").merge();
audit.getRange("A3").values = [["Every FAIL blocks that record from the Graph change plan."]];
audit.getRange("A3").format.font = { name: fontFamily, size: 10, italic: true, color: "#5B6573" };
audit.getRange("A5:H5").values = [["EmployeeId", "Duplicate ID", "Manager reference", "Department", "Lifecycle action", "Leaver end date", "Source system", "Overall"]];
audit.getRange("A6:A25").formulas = employeeRows.map((_, index) => [`=Employees!A${index + 6}`]);
for (let row = 6; row <= 25; row++) {
  audit.getRange(`B${row}:H${row}`).formulas = [[
    `=IF(COUNTIF(Employees!$A$6:$A$25,Employees!A${row})>1,"Duplicate EmployeeId","")`,
    `=IF(AND(Employees!H${row}<>"",COUNTIF(Employees!$A$6:$A$25,Employees!H${row})=0),"Manager not found","")`,
    `=IF(COUNTIF(Reference!$A$5:$A$10,Employees!E${row})=0,"Invalid department","")`,
    `=IF(COUNTIF(Reference!$C$5:$C$7,Employees!K${row})=0,"Invalid action","")`,
    `=IF(AND(Employees!K${row}="Disable",Employees!N${row}=""),"End date required","")`,
    `=IF(COUNTIF(Reference!$G$5:$G$5,Employees!P${row})=0,"Invalid source","")`,
    `=IF(OR(B${row}<>"",C${row}<>"",D${row}<>"",E${row}<>"",F${row}<>"",G${row}<>""),"FAIL","PASS")`,
  ]];
}
audit.getRange("A5:H5").format = { fill: navy, font: { name: fontFamily, size: 10, bold: true, color: "#FFFFFF" }, horizontalAlignment: "center", wrapText: true };
audit.getRange("A6:H25").format.font = { name: fontFamily, size: 10, color: darkText };
audit.tables.add("A5:H25", true, "HrValidationTable").style = "TableStyleMedium2";
audit.getRange("H6:H25").conditionalFormats.add("containsText", { text: "FAIL", format: { fill: redFill, font: { bold: true, color: redText } } });
audit.getRange("H6:H25").conditionalFormats.add("containsText", { text: "PASS", format: { fill: greenFill, font: { bold: true, color: greenText } } });
audit.freezePanes.freezeRows(5);
audit.getRange("A:A").format.columnWidth = 14;
audit.getRange("B:G").format.columnWidth = 22;
audit.getRange("H:H").format.columnWidth = 12;

overview.tabColor = navy;
employees.tabColor = blue;
mapping.tabColor = "#5B9BD5";
audit.tabColor = "#A5A5A5";
reference.tabColor = "#A5A5A5";

workbook.recalculate();

const overviewInspect = await workbook.inspect({
  kind: "table",
  range: "Overview!A1:H13",
  include: "values,formulas",
  tableMaxRows: 20,
  tableMaxCols: 10,
});
await fs.writeFile(path.join(outputDir, "overview-inspect.ndjson"), overviewInspect.ndjson, "utf8");

const auditInspect = await workbook.inspect({
  kind: "table",
  range: "Audit!A5:H25",
  include: "values,formulas",
  tableMaxRows: 25,
  tableMaxCols: 10,
});
await fs.writeFile(path.join(outputDir, "audit-inspect.ndjson"), auditInspect.ndjson, "utf8");

const errorInspect = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!",
  options: { useRegex: true, maxResults: 300 },
  summary: "final formula error scan",
});
await fs.writeFile(path.join(outputDir, "formula-errors.ndjson"), errorInspect.ndjson, "utf8");

for (const [sheetName, fileName, range] of [
  ["Overview", "overview-preview.png", "A1:H14"],
  ["Employees", "employees-preview.png", "A1:Q25"],
  ["IAM Mapping", "mapping-preview.png", "A1:F17"],
  ["Audit", "audit-preview.png", "A1:H25"],
  ["Reference", "reference-preview.png", "A1:H11"],
]) {
  const preview = await workbook.render({ sheetName, range, scale: 1, format: "png" });
  await fs.writeFile(path.join(outputDir, fileName), new Uint8Array(await preview.arrayBuffer()));
}

const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(path.join(outputDir, "enterprise-hr-identity-source.xlsx"));

console.log(path.join(outputDir, "enterprise-hr-identity-source.xlsx"));
