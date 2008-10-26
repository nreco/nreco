using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Xml;
using System.Xml.XPath;
using System.IO;

using NI.Common;
using NReco.Transform;

namespace NReco.Winter {
	
	public class RuleConfigProcessor : NI.Common.Xml.IModifyXmlDocumentHandler {
		IFileManager _FileManager;

		public IFileManager FileManager {
			get { return _FileManager; }
			set { _FileManager = value; }
		}
		
		public RuleConfigProcessor() {
		}

		public RuleConfigProcessor(IFileManager fm) {
			FileManager = fm;
		}

		public void Modify(XmlDocument xmlDocument) {
			XmlNodeList ruleNodes = xmlDocument.SelectNodes(".//*[name()='xsl-transform']");
			XmlNode[] sortedRuleNodes = SortRuleNodes(ruleNodes);
			foreach (XmlNode ruleNode in sortedRuleNodes) {
				ProcessRuleNode(ruleNode);
				// remove 'rule' node
				ruleNode.ParentNode.RemoveChild(ruleNode);
			}
			//Console.WriteLine(xmlDocument.OuterXml);
		}

		protected virtual void ProcessRuleNode(XmlNode ruleNode) {
			if (ruleNode.Name=="xsl-transform") {
				XslTransformRule xsltRule = new XslTransformRule();
				XslTransformRule.Context xsltContext = new XslTransformRule.Context();
				xsltContext.FileManager = FileManager;
				xsltContext.ReadFromXmlNode( ruleNode );
				string result = xsltRule.Provide( xsltContext );

				InsertXml( ruleNode, result );
			}
		}

		protected void InsertXml(XmlNode ruleNode, string xml) {
			XmlNode parentNode = ruleNode.ParentNode;
			XmlTextReader xmlRdr = new XmlTextReader(xml, XmlNodeType.Element, new XmlParserContext(null, null, null, XmlSpace.Preserve));
			while (!xmlRdr.EOF) {
				XmlNode node;
				try {
					node = parentNode.OwnerDocument.ReadNode(xmlRdr);
				} catch (Exception ex) {
					throw new Exception("Cannot read node", ex);
				}
				if (node!=null && node.NodeType!=XmlNodeType.XmlDeclaration)
					try {
						if (node.Name=="components") {
							foreach (XmlNode n in node.ChildNodes) {
								XmlNode insertedNode = parentNode.InsertBefore(node, ruleNode);
							}
						} else {
							XmlNode insertedNode = parentNode.InsertBefore(node, ruleNode);
							//ModifyNode(insertedNode);
						}
					} catch (Exception ex) {
						throw new Exception(
							String.Format("Cannot insert node {0}", node.NodeType), ex);
					}
			}

		}


		protected XmlNode[] SortRuleNodes(XmlNodeList importNodes) {
			XmlNode[] result = new XmlNode[importNodes.Count];
			for (int i=0; i<result.Length; i++)
				result[i] = importNodes[i];

			Array.Sort(result, new NodeDepthComparer());
			return result;
		}

		class NodeDepthComparer : IComparer {

			public int Compare(object x, object y) {
				XmlNode xNode = (XmlNode)x;
				XmlNode yNode = (XmlNode)y;
				return CalcDepth(yNode).CompareTo(CalcDepth(xNode));
			}

			protected int CalcDepth(XmlNode node) {
				int len = 0;
				while (node.ParentNode!=null) {
					len++;
					node = node.ParentNode;
				}
				return len;
			}

		}

	}
}
