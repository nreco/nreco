using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

using NUnit.Framework;
using NReco.Transform;

namespace NReco.Tests
{
    [TestFixture]
    public class LocalFileManagerTests
    {
        [Test]
        public void ReadContentFileTest()
        {
            DirectoryInfo di = Directory.CreateDirectory(Path.Combine(Path.GetTempPath(), "NReco_LocalFileManagerTest"));
            string testDir = di.FullName;
            string testFilePath = Path.Combine(testDir, "file1.txt");
            string test_text = "This is a NUnit test for LocalFileManager class!";
            using (FileStream fs = File.Create(testFilePath))
            {
                AddText(fs, test_text);
                fs.Flush();
                fs.Close();
            }

            LocalFileManager localFileManager = new LocalFileManager();

            localFileManager.RootPath = di.FullName;
            Assert.AreEqual(localFileManager.Read(testFilePath), test_text);
            Assert.AreNotEqual(localFileManager.Read(testFilePath), "This is a wrong text! ");

            File.Delete(testFilePath);
            Directory.Delete(testDir);
        }

        [Test]
        public void WriteContentToFileTest()
        {
            DirectoryInfo di = Directory.CreateDirectory(Path.Combine(Path.GetTempPath(), "NReco_LocalFileManagerTest"));
            string testDir = di.FullName;
            string testFilePath = Path.Combine(testDir, "file2.txt");
            string testContentText = "This is a text write by using class LocalFileManager!";

            LocalFileManager localFileManager = new LocalFileManager();
            localFileManager.Write(testFilePath, testContentText);

            string readText = File.ReadAllText(testFilePath);

            Assert.AreEqual(testContentText, readText);
            Assert.AreEqual(testContentText, localFileManager.Read(testFilePath));

            File.Delete(testFilePath);
            Directory.Delete(testDir);
        }

        [Test]
        public void ReadContentFilesTest()
        {
            DirectoryInfo di = Directory.CreateDirectory(Path.Combine(Path.GetTempPath(), "NReco_LocalFileManagerTest"));
            DirectoryInfo subDi = Directory.CreateDirectory(Path.Combine(di.FullName, "subfolder_NReco_LocalFileManagerTest"));
            string testFilePath = Path.Combine(di.FullName, "file2.txt");
            string testSubFolderFilePath = Path.Combine(subDi.FullName, "file3.txt");
            string testContentText = "This is a text write by using class LocalFileManager!";
            string testSubFolderFileContent = "This is a content secondery file!";
            int contentLength = testContentText.Length + testSubFolderFileContent.Length;

            using (FileStream fs = File.Create(testFilePath))
            {
                AddText(fs, testContentText);
                fs.Flush();
                fs.Close();
            }
            using (FileStream fs = File.Create(testSubFolderFilePath))
            {
                AddText(fs, testSubFolderFileContent);
                fs.Flush();
                fs.Close();
            }

            LocalFileManager localFileManager = new LocalFileManager();

            localFileManager.RootPath = di.FullName;
            Assert.AreEqual(localFileManager.Read("*.txt").Length, contentLength);

            File.Delete(testSubFolderFilePath);
            Directory.Delete(subDi.FullName);
            File.Delete(testFilePath);
            Directory.Delete(di.FullName);
        }

        protected void AddText(FileStream fs, string value)
        {
            byte[] info = new UTF8Encoding(true).GetBytes(value);
            fs.Write(info, 0, info.Length);  
        }
    }
}
