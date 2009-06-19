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
using NReco.SemWeb;

namespace NReco.SemWeb.Model {
	
	/// <summary>
	/// RDF Resource 'view'
	/// </summary>
	public class ResourceView {
		IList<Statement> Statements = null;
		SelectableSource Source;
		IDictionary<ResourceView, object> CachedLiteralProps = null;

		public Entity Uid { get; protected set; }

		public string Label {
			get {
				foreach (var s in Statements)
					if (s.Predicate == NS.Rdfs.labelEntity && s.Object is Literal) {
						var lit = (Literal)s.Object;
						return lit.Value;
					}
				return null;
			}
		}

		public ResourceView Type {
			get {
				foreach (var s in Statements)
					if (s.Predicate == NS.Rdf.typeEntity)
						return new ResourceView( (Entity)s.Object, Source );
				return null;
			}
		}

		/// <summary>
		/// Resource 'primitive' properties
		/// </summary>
		public IDictionary<ResourceView,object> Literals {
			get {
				EnsureLiteralProps();
				return CachedLiteralProps;
			}
		}

		public ResourceView GetReference(Entity property) {
			foreach (var s in Statements)
				if (s.Predicate == property && s.Object is Entity)
					return new ResourceView( (Entity)s.Object, Source);
			return null;
		}

		public ResourceView(string resourceUri, SelectableSource source) {
			Uid = new Entity(resourceUri);
			Source = source;
		}

		public ResourceView(Entity resourceEntity, SelectableSource source) {
			Uid = resourceEntity;
			Source = source;
		}

		protected void EnsureStatements() {
			if (Statements == null)
				Statements = Source.SelectAll(new Statement(Uid, null, null));
		}

		protected void EnsureLiteralProps() {
			if (CachedLiteralProps != null)
				return;

			CachedLiteralProps = new Dictionary<ResourceView,object>();
			var groups = new Dictionary<Entity, IList<Resource>>();

			// collect and group-by-property literals
			var q = from s in Statements
					where !NS.Rdfs.IsLiteralProperty(s.Predicate) && (s.Object is Literal) //TODO: also rdf:Bag/Sequence handling should be here
					select s;
			foreach (var st in q) {
				if (!groups.ContainsKey(st.Predicate))
					groups[st.Predicate] = new List<Resource>();
				if (!groups[st.Predicate].Contains(st.Object))
					groups[st.Predicate].Add(st.Object);
			}
			// TBD
		}


	}
}
