const fs = require('fs');
const { markdownToDocx } = require('markdown-docx');

async function convertMdToDocx(inputFile, outputFile) {
  try {
    const markdown = fs.readFileSync(inputFile, 'utf-8');
    const docxBuffer = await markdownToDocx(markdown);
    fs.writeFileSync(outputFile, docxBuffer);
    console.log(`✓ 转换成功: ${inputFile} -> ${outputFile}`);
  } catch (error) {
    console.error(`✗ 转换失败: ${inputFile}`, error.message);
  }
}

async function main() {
  const files = [
    { input: 'docs/前端需求文档.md', output: 'docs/前端需求文档.docx' },
    { input: 'docs/后端功能列表.md', output: 'docs/后端功能列表.docx' },
    { input: 'docs/API接口文档.md', output: 'docs/API接口文档.docx' }
  ];

  for (const file of files) {
    await convertMdToDocx(file.input, file.output);
  }
}

main();
