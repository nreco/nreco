using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml;
using System.Xml.XPath;

using NUnit.Framework;
using NReco.Transform;
using Moq;

namespace NReco.Tests.Transform {

	[TestFixture]
	public class ModifyXmlFileRuleTests {

		protected XPathNavigator GetRuleNav(string rule) {
			var ruleXPathDoc1 = new XPathDocument(
				new StringReader(rule));
			return ruleXPathDoc1.CreateNavigator().SelectSingleNode("/*");
		}

		[Test]
		public void InsertTest() {
			var rule = new ModifyXmlFileRule();

			var fmMock = new Mock<IFileManager>();
			fmMock.Setup(fm => fm.Read("test.xml")).Returns(
				"<root><a>a1</a><a>a2</a><b>b</b></root>");

			var ruleNav1 = GetRuleNav(
				@"<xml-insert file='test.xml' mode='after' xpath='/root/a[position()=last()]'><z>Z</z></xml-insert>");
			Assert.IsTrue(rule.IsMatch(ruleNav1));
			rule.Execute(new FileRuleContext("a", fmMock.Object, ruleNav1));
			rule.Execute(new FileRuleContext("a", fmMock.Object, GetRuleNav(
				@"<xml-insert file='test.xml' mode='child' xpath='/root/a[position()=1]'><X>1</X></xml-insert>") ));

			fmMock.Verify(fm => fm.Read("test.xml"), Times.AtLeastOnce() );
			fmMock.Verify(fm => fm.Write("test.xml", "<root><a>a1</a><a>a2</a><z>Z</z><b>b</b></root>"), Times.Exactly(1));
			fmMock.Verify(fm => fm.Write("test.xml", "<root><a>a1<X>1</X></a><a>a2</a><b>b</b></root>"), Times.Exactly(1));
		}

		[Test]
		public void RemoveTest() {
			var rule = new ModifyXmlFileRule();

			var fmMock = new Mock<IFileManager>();
			fmMock.Setup(fm => fm.Read("test.xml")).Returns(
				"<root><a>a1</a><a>a2</a><b>b</b></root>");

			var ruleNav1 = GetRuleNav(
				@"<xml-remove file='test.xml' xpath='/root/a[position()=2]'/>");
			rule.Execute(new FileRuleContext("a", fmMock.Object,ruleNav1));
			fmMock.Verify(fm => fm.Write("test.xml", "<root><a>a1</a><b>b</b></root>"), Times.Exactly(1));
		}

		[Test]
		public void ReplaceTest() {
			var rule = new ModifyXmlFileRule();

			var fmMock = new Mock<IFileManager>();
			fmMock.Setup(fm => fm.Read("test.xml")).Returns(
				"<root><a>a1</a><a>a2</a><b>b</b></root>");

			var ruleNav1 = GetRuleNav(
				@"<xml-replace file='test.xml' xpath='/root/b'><b>c</b></xml-replace>");
			rule.Execute(new FileRuleContext("a", fmMock.Object, ruleNav1));
			fmMock.Verify(fm => fm.Write("test.xml", "<root><a>a1</a><a>a2</a><b>c</b></root>"), Times.Exactly(1));

			var ruleNav2 = GetRuleNav(
				@"<xml-replace file='test.xml' xpath='/root/b'><c>c</c></xml-replace>");
			rule.Execute(new FileRuleContext("a", fmMock.Object, ruleNav2));
			fmMock.Verify(fm => fm.Write("test.xml", "<root><a>a1</a><a>a2</a><c>c</c></root>"), Times.Exactly(1));

		}


	}
}
