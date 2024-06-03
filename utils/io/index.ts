const fs = require("fs");

export async function write(filePath: string, fileName: string, content: string) {
  try {
    await fs.statSync(filePath);
  } catch (err) {
    await fs.mkdirSync(filePath);
  }finally {
    await fs.writeFileSync(filePath + "\\" + fileName, content);
  }
}
