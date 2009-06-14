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
		IList<Statement> Statements;
		StatementSource Source;

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
		/// Resource significant properties enumeration
		/// </summary>
		public IEnumerable<Entity> Properties {
			get {
				var list = new List<Entity>();
				var q = from s in Statements
						where s.Predicate != NS.Rdf.typeEntity
						select s.Predicate;
				return q;
			}
		}

		public ResourceView GetReference(Entity property) {
			foreach (var s in Statements)
				if (s.Predicate == property && s.Object is Entity)
					return new ResourceView( (Entity)s.Object, Source);
			return null;
		}

		public ResourceView(string resourceUri, StatementSource source) {
			Uid = new Entity(resourceUri);
			Source = source;
		}

		public ResourceView(Entity resourceEntity, StatementSource source) {
			Uid = resourceEntity;
			Source = source;
		}


		


	}
}
