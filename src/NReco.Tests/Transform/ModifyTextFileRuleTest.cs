using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.IO;
using System.Xml;
using System.Xml.XPath;

using NUnit.Framework;
using NReco.Transform;

namespace NReco.Tests.Transform
{
    [TestFixture]
    public class ModifyTextFileRuleTest
    {
        #region properties
		protected DirectoryInfo TestDiretoryInfo { get; set; }

		protected string TestDiretoryPath { get; set; }

		protected string TestFilePath { get; set; }

		protected string TestXmlFilePath { get; set; }
        #endregion

        [Test]
        public void InsertTextFileTest()
        {
            CreateTestDirectoryAndFiles();

            string insertNode = "test1";
            string test_text = "<text-insert file=\"test3.result.xml\" start=\"&lt;test&gt;\"><" + insertNode + "/></text-insert>";

            string xmlContent = "<test><t2>bbb</t2></test>";
            
            ModifyTextFileRule modifyTextFileRule = new ModifyTextFileRule();
            IFileManager fileManager = new LocalFileManager(TestDiretoryPath);

            using (FileStream fs = File.Create(TestFilePath))
            {
                AddText(fs, test_text);
                fs.Flush();
                fs.Close();
            }
            using (FileStream fs = File.Create(TestXmlFilePath))
            {
                AddText(fs, xmlContent);
                fs.Flush();
                fs.Close();
            }

			XPathDocument ruleXPathDoc = new XPathDocument(new StringReader(test_text) );
			XPathNavigator ruleFileNav = ruleXPathDoc.CreateNavigator().SelectSingleNode("/*");
			Console.WriteLine(ruleFileNav.LocalName);

			bool isMatched = modifyTextFileRule.IsMatch(ruleFileNav);
            Assert.AreEqual(true, isMatched);

			FileRuleContext fileRuleContext = new FileRuleContext(TestFilePath, fileManager, ruleFileNav);

            modifyTextFileRule.Execute(fileRuleContext);
            Assert.AreEqual(true, File.ReadAllText(TestXmlFilePath).Contains(insertNode));

            Assert.AreEqual(true, IsNodeInXmlFile(TestXmlFilePath, insertNode));
            DeleteTestDirectoryAndFiles();
        }

        [Test]
        public void ReplaceTextFileTest()
        {
            CreateTestDirectoryAndFiles();

            string replaceText = "ggg";
            string test_text = "<text-replace file=\"test3.result.xml\" regex=\"t2\">" + replaceText + "</text-replace>";

            string xmlContent = "<test><t2>bbb</t2></test>";

            ModifyTextFileRule modifyTextFileRule = new ModifyTextFileRule();
            IFileManager fileManager = new LocalFileManager(TestDiretoryPath);

            using (FileStream fs = File.Create(TestFilePath))
            {
                AddText(fs, test_text);
                fs.Flush();
                fs.Close();
            }
            using (FileStream fs = File.Create(TestXmlFilePath))
            {
                AddText(fs, xmlContent);
                fs.Flush();
                fs.Close();
            }

			XPathDocument ruleXPathDoc = new XPathDocument(new StringReader(test_text));
			XPathNavigator ruleFileNav = ruleXPathDoc.CreateNavigator().SelectSingleNode("/*");

			FileRuleContext fileRuleContext = new FileRuleContext(TestFilePath, fileManager, ruleFileNav);

            modifyTextFileRule.Execute(fileRuleContext);
            Assert.AreEqual(true, File.ReadAllText(TestXmlFilePath).Contains(replaceText));

            Assert.AreEqual(true, IsNodeInXmlFile(TestXmlFilePath, replaceText));

            DeleteTestDirectoryAndFiles();
        }

        [Test]
        public void RemoveItemFromFileTest()
        {
            CreateTestDirectoryAndFiles();
            string test_text = "<text-remove file=\"test3.result.xml\" regex=\"bbb\"></text-remove>";

            string xmlContent = "<test><t2>bbb</t2></test>";

            ModifyTextFileRule modifyTextFileRule = new ModifyTextFileRule();
            IFileManager fileManager = new LocalFileManager(TestDiretoryPath);

            using (FileStream fs = File.Create(TestFilePath))
            {
                AddText(fs, test_text);
                fs.Flush();
                fs.Close();
            }
            using (FileStream fs = File.Create(TestXmlFilePath))
            {
                AddText(fs, xmlContent);
                fs.Flush();
                fs.Close();
			}
			XPathDocument ruleXPathDoc = new XPathDocument(new StringReader(test_text));
			XPathNavigator ruleFileNav = ruleXPathDoc.CreateNavigator().SelectSingleNode("/*");

			FileRuleContext fileRuleContext = new FileRuleContext(TestFilePath, fileManager,ruleFileNav);

            modifyTextFileRule.Execute(fileRuleContext);

            Assert.AreEqual(false, File.ReadAllText(TestXmlFilePath).Contains("bbb"));

        }

        protected void AddText(FileStream fs, string value)
        {
            byte[] info = new UTF8Encoding(true).GetBytes(value);
            fs.Write(info, 0, info.Length);
        }

        protected void CreateTestDirectoryAndFiles()
        {
            TestDiretoryInfo = Directory.CreateDirectory(Path.Combine(Path.GetTempPath(), "NReco_ModifyTextFileRuleTest"));
            TestDiretoryPath = TestDiretoryInfo.FullName;
            TestFilePath = Path.Combine(TestDiretoryPath, "@TestFile.txt");
            TestXmlFilePath = Path.Combine(TestDiretoryPath, "test3.result.xml");
        }

        protected void DeleteTestDirectoryAndFiles()
        {
            File.Delete(TestFilePath);
            File.Delete(TestXmlFilePath);
            Directory.Delete(TestDiretoryPath);
        }

        protected bool IsNodeInXmlFile(string filePath, string nodeName)
        {
            XmlTextReader reader = new XmlTextReader(filePath);
            XmlDocument doc = new XmlDocument();
            doc.Load(reader);

            XmlNodeList nodes = doc.DocumentElement.SelectNodes("//test");

            foreach (XmlNode n in nodes)
            {
                if (nodeName.Trim() == n.FirstChild.Name.Trim())
                {
                    reader.Close();
                    return true;
                }
            }
            reader.Close();
            return false;
        }
    }
}
