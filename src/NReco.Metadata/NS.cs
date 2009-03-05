using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using SemWeb;

namespace NReco.Metadata {
	
	public class NS {
		public const string NrMeta = "urn:schemas-nreco:metadata#";
		public const string NrNetType = NrMeta;
		public const string NrNetImplement = NrMeta + "#implement";

		public const string Rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
		public const string RdfType = Rdf + "type";

		public const string Rdfs = "http://www.w3.org/2000/01/rdf-schema#";
		public const string RdfsClass = Rdfs+"Class";
		public const string RdfsSubClassOf = Rdfs + "subClassOf";
		public const string RdfsSubPropertyOf = Rdfs + "subPropertyOf";
		public const string RdfsDomain = Rdfs + "domain";
		public const string RdfsRange = Rdfs + "range";
		public const string RdfsResource = Rdfs + "Resource";
		public const string RdfsLabel = Rdfs + "label";
		public const string RdfsComment = Rdfs + "comment";
		public const string RdfsMember = Rdfs + "member";

		public static readonly Entity NrNetImplementEntity = NrNetImplement;
		public static readonly Entity RdfTypeEntity = RdfType;
		public static readonly Entity RdfsClassEntity = RdfsClass;
		public static readonly Entity RdfsSubClassOfEntity = RdfsSubClassOf;
		public static readonly Entity RdfsSubPropertyOfEntity = RdfsSubPropertyOf;
	}
}
