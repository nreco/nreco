#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using SemWeb;

namespace NReco.SemWeb {
	
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
			public static readonly Entity labelEntity = label;
			public static readonly Entity commentEntity = comment;

			public static bool IsLiteralProperty(Entity property) {
				return property == labelEntity || property == commentEntity;
			}
		}

		public static class Owl {
			public const string BASE = "http://www.w3.org/2002/07/owl#";
			public const string Ontology = BASE + "Ontology";
			public const string Class = BASE + "Class";
			public const string Thing = BASE + "Thing";
			public const string TransitiveProperty = BASE + "TransitiveProperty";
			public const string FunctionalProperty = BASE + "FunctionalProperty";
			public const string ObjectProperty = BASE + "ObjectProperty";
			public const string SymmetricProperty = BASE + "SymmetricProperty";
			public const string DatatypeProperty = BASE + "DatatypeProperty";
			
			public const string equivalentClass = BASE + "equivalentProperty";
			public const string equivalentProperty = BASE + "equivalentProperty";
			public const string sameAs = BASE + "sameAs";
			public const string differentFrom = BASE + "differentFrom";
			public const string inverseOf = BASE + "inverseOf";
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
