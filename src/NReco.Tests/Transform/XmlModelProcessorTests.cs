using System;
using System.Collections.Generic;
using System.Collections;
using System.Diagnostics;
using System.Text;
using System.IO;
using NUnit.Framework;

using NReco;
using NReco.Transform;
using NI.Vfs;

namespace NReco.Tests.Transform {

	[TestFixture]
	public class XmlModelProcessorTests {

		protected IFileSystem createTestFs() {
			var memFs = new MemoryFileSystem();
			var config = memFs.ResolveFile("config");
			config.CreateFolder();

			var dsmFile = memFs.ResolveFile("config/test.dsm");
			dsmFile.CopyFrom(new MemoryStream(Encoding.UTF8.GetBytes(testDsmContent)));

			var dsmMultiFile = memFs.ResolveFile("config/testMulti.dsm");
			dsmMultiFile.CopyFrom(new MemoryStream(Encoding.UTF8.GetBytes(testMultiFileDsmContent)));

			var xsltFolder = memFs.ResolveFile("config/xslt");
			xsltFolder.CreateFolder();

			var xsltFile = memFs.ResolveFile("config/xslt/transform.xsl");
			xsltFile.CopyFrom(new MemoryStream(Encoding.UTF8.GetBytes(testXslContent)));

			var xsltMultiFile = memFs.ResolveFile("config/xslt/transform_multi.xsl");
			xsltMultiFile.CopyFrom(new MemoryStream(Encoding.UTF8.GetBytes(testMultiXslContent)));

			var genFolder = memFs.ResolveFile("generated");
			genFolder.CreateFolder();

			return memFs;
		}

		const string testDsmContent = @"<?xml version=""1.0""?>
<?xml-stylesheet type=""text/xsl"" href=""xslt/transform.xsl"" output-file=""test.out""?>
<model>
	<test1>test1</test1>
</model>
";

		const string testMultiFileDsmContent = @"<?xml version=""1.0""?>
<?xml-stylesheet type=""text/xsl"" href=""xslt/transform_multi.xsl"" output-file=""*"" output-base-path=""../generated""?>
<model>
	<file name=""test1.ascx"">test1content</file>
	<file name=""test2.ascx"">test2content</file>
</model>
";

		const string testXslContent = @"
<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform"">
<xsl:template match=""/model""><xsl:value-of select=""test1""/></xsl:template>
</xsl:stylesheet>
";

		const string testMultiXslContent = @"
<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform"">
<xsl:template match=""/model""><files><xsl:copy-of select=""file""/></files></xsl:template>
</xsl:stylesheet>
";

		[Test]
		public void TransformModel() {
			var fs = createTestFs();
			var modelProcessor = new XmlModelProcessor(fs);
			modelProcessor.TransformModel("config/test.dsm");

			var outFile = fs.ResolveFile("config/test.out");
			Assert.AreEqual(FileType.File, outFile.Type);

			using (var outFileStream = outFile.GetContent().InputStream) {
				var outFileContent = new StreamReader(outFileStream).ReadToEnd();
				Assert.AreEqual("test1", outFileContent.Trim());
			}

			modelProcessor.TransformModel("config/testMulti.dsm");
			var generatedFolder = fs.ResolveFile("generated");
			Assert.AreEqual(2, generatedFolder.GetChildren().Length);

			var test1File = fs.ResolveFile("generated/test1.ascx");
			using (var fstream = test1File.GetContent().InputStream) {
				var outFileContent = new StreamReader(fstream).ReadToEnd();
				Assert.AreEqual("test1content", outFileContent.Trim());
			}
		}




	}
}
