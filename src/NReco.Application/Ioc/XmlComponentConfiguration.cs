using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace NReco.Application.Ioc {
	
	public class XmlComponentConfiguration : NI.Ioc.XmlComponentConfiguration {

		public string[] SourceFileNames { get; set; }

		public XmlComponentConfiguration(XmlReader configXmlReader)
			: base(configXmlReader) {
		}
		
	}
}
