using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using SemWeb;

namespace NReco.Metadata {
	
	public static class NS {
		public const string NrMeta = "urn:schemas-nreco:metadata";
		public const string NrMetaTerms = NrMeta + ":terms#";
		public const string NrDepFrom = NrMetaTerms + "dependentFrom";

		public static readonly Entity NrDepFromEntity = NrDepFrom;

		public static class DotNet {
			public const string Type = NrMeta + ":dotnet:type#";
			public const string Property = NrMeta + ":dotnet:property#";

			public static Entity GetTypeEntity(Type t) {
				string fullName = t.Namespace + "." + t.Name.Replace("`", "-G");;
				return new Entity(Type + fullName.Replace('.','_') );
			}
			public static Entity GetPropertyEntity(string pName) {
				return new Entity(Property + pName);
			}
		}

		public static class Rdf {
			public const string BASE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
			public const string type = BASE + "type";
			public const string Bag = BASE + "Bag";
			public const string Seq = BASE + "Seq";
			public const string Alt = BASE + "Alt";

			public static readonly Entity typeEntity = type;
			public static readonly Entity BagEntity = Bag;
			public static readonly Entity SeqEntity = Seq;
		}

		public static class Rdfs {
			public const string BASE = "http://www.w3.org/2000/01/rdf-schema#";
			public const string Class = BASE + "Class";
			public const string Property = BASE + "Property";
			public const string subClassOf = BASE + "subClassOf";
			public const string subPropertyOf = BASE + "subPropertyOf";
			public const string domain = BASE + "domain";
			public const string range = BASE + "range";
			public const string Resource = BASE + "Resource";
			public const string label = BASE + "label";
			public const string comment = BASE + "comment";
			public const string member = BASE + "member";

			public static readonly Entity ClassEntity = Class;
			public static readonly Entity PropertyEntity = Property;
			public static readonly Entity subClassOfEntity = subClassOf;
			public static readonly Entity subPropertyOfEntity = subPropertyOf;
			public static readonly Entity domainEntity = domain;
		}

		public static class CSO {
			public const string BASE = "http://cos.ontoware.org/cso#";
			public const string Interface = BASE + "interface";
			public const string Method = BASE + "method";
			public const string Implements = BASE + "implements";
			public const string Class = BASE + "class";

			public static readonly Entity interfaceEntity = Interface;
			public static readonly Entity classEntity = Class;
		}

	}
}
