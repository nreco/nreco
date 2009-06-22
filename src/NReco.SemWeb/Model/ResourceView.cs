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
		IDictionary<ResourceView, object> ValueProperties = null;
		IDictionary<ResourceView, IList<ResourceView>> ReferenceProperties = null;

		public Entity Uid { get; protected set; }

		public string Label {
			get {
				EnsureData();
				var lblResource = new ResourceView(NS.Rdfs.labelEntity, Source);
				if (ValueProperties.ContainsKey(lblResource))
					return ValueProperties[lblResource].ToString();
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
		public IDictionary<ResourceView,object> Properties {
			get {
				EnsureData();
				return ValueProperties;
			}
		}

		public ResourceView(string resourceUri, SelectableSource source) {
			Uid = new Entity(resourceUri);
			Source = source;
		}

		public ResourceView(Entity resourceEntity, SelectableSource source) {
			Uid = resourceEntity;
			Source = source;
		}

		protected void EnsureData() {
			if (Statements == null)
				Statements = Source.SelectAll(new Statement(Uid, null, null));

			ValueProperties = new Dictionary<ResourceView, object>();
			ReferenceProperties = new Dictionary<ResourceView, IList<ResourceView>>();
			var groups = new Dictionary<Entity, IList<Resource>>();

			// collect and group-by-property
			foreach (var st in Statements) {
				if (!groups.ContainsKey(st.Predicate))
					groups[st.Predicate] = new List<Resource>();
				if (!groups[st.Predicate].Contains(st.Object))
					groups[st.Predicate].Add(st.Object);
			}

			foreach (var group in groups) {
				var valueList = new List<object>();
				var refList = new List<ResourceView>();

			}

			
		}

		public bool IsProperty {
			get { return Source.Contains(new Statement(Uid, NS.Rdf.typeEntity, NS.Rdfs.PropertyEntity)); }
		}

		public override int GetHashCode() {
			return Uid.GetHashCode();
		}

		public override bool Equals(object obj) {
			if (obj is ResourceView)
				return Uid.Equals(((ResourceView)obj).Uid);
			return base.Equals(obj);
		}

	}
}
