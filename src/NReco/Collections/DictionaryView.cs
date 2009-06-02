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
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace NReco.Collections {

	/// <summary>
	/// Dictionary 'view' (like DataRowView) wrapper.
	/// </summary>
	[Serializable]
	public class DictionaryView : ICustomTypeDescriptor {
		public IDictionary Data;

		public DictionaryView(IDictionary data) {
			Data = data;
		}

		public object this[string fldName] {
			get {
				return Data[fldName];
			}
			set {
				Data[fldName] = value;
			}
		}

		#region ICustomTypeDescriptor

		AttributeCollection ICustomTypeDescriptor.GetAttributes() {
			return new AttributeCollection(null);
		}

		string ICustomTypeDescriptor.GetClassName() {
			return null;
		}

		string ICustomTypeDescriptor.GetComponentName() {
			return null;
		}

		TypeConverter ICustomTypeDescriptor.GetConverter() {
			return null;
		}

		EventDescriptor ICustomTypeDescriptor.GetDefaultEvent() {
			return null;
		}

		PropertyDescriptor ICustomTypeDescriptor.GetDefaultProperty() {
			return null;
		}

		object ICustomTypeDescriptor.GetEditor(Type editorBaseType) {
			return null;
		}

		EventDescriptorCollection ICustomTypeDescriptor.GetEvents(Attribute[] attributes) {
			return new EventDescriptorCollection(null);
		}

		EventDescriptorCollection ICustomTypeDescriptor.GetEvents() {
			return new EventDescriptorCollection(null);
		}

		PropertyDescriptorCollection ICustomTypeDescriptor.GetProperties(Attribute[] attributes) {
			var props = new List<PropertyDescriptor>();
			foreach (DictionaryEntry varEntry in Data)
				props.Add(new DictionaryViewPropertyDescriptor(varEntry.Key.ToString()));
			return new PropertyDescriptorCollection(props.ToArray());
		}

		PropertyDescriptorCollection ICustomTypeDescriptor.GetProperties() {
			return ((ICustomTypeDescriptor)this).GetProperties(null);
		}

		object ICustomTypeDescriptor.GetPropertyOwner(PropertyDescriptor pd) {
			return this;
		}

		#endregion

		internal class DictionaryViewPropertyDescriptor : PropertyDescriptor {
			string Name;

			public DictionaryViewPropertyDescriptor(string name)
				: base(name, null) {
				Name = name;
			}

			public override bool CanResetValue(object component) {
				return true;
			}

			public override Type ComponentType {
				get { return typeof(DictionaryView); }
			}

			public override object GetValue(object component) {
				return ((DictionaryView)component)[Name];
			}

			public override bool IsReadOnly {
				get { return false; }
			}

			public override Type PropertyType {
				get { return typeof(object); }
			}

			public override void ResetValue(object component) {
				((DictionaryView)component)[Name] = null;
			}

			public override void SetValue(object component, object value) {
				((DictionaryView)component)[Name] = value;
			}

			public override bool ShouldSerializeValue(object component) {
				return false;
			}
		}


	}


}
