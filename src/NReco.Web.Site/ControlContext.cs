using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web.Site {

	public class ControlContext : IDictionary {
		Control Ctrl;
		IEnumerable<SourceType> Order;
		string AttributePrefix = "context_";

		public enum SourceType {
			Request, Route, Attributes, DataContext
		}

		public virtual HttpRequest Request {
			get { return HttpContext.Current.Request; }
		}

		public virtual IDictionary<string, object> Route {
			get { return Ctrl.GetRouteContext(); }
		}

		public virtual AttributeCollection Attributes {
			get { return Ctrl!=null && Ctrl is WebControl ? ((WebControl)Ctrl).Attributes : null; }
		}

		public ControlContext(Control ctrl) {
			Order = new[] { SourceType.DataContext, SourceType.Attributes, SourceType.Route, SourceType.Request };
			Ctrl = ctrl;
		}

		public object this[string key] {
			get {
				object res = null;
				foreach (var source in Order)
					if (GetSourceValue(key, source, out res))
						return res;
				return null;
			}
		}

		protected bool GetSourceValue(string key, SourceType source, out object val) {
			val = null;
			switch (source) {
				case SourceType.Request:
					val = Request[key];
					return val != null;
				case SourceType.Attributes:
					var attrKey = AttributePrefix + key;
					if (Attributes != null && Attributes[attrKey] != null) {
						val = Attributes[attrKey];
						return true;
					}
					return false;
				case SourceType.Route:
					var route = Route;
					if (route != null && route.ContainsKey(key) ) {
						val = route[key];
						return true;
					}
					return false;
				case SourceType.DataContext:
					if (Ctrl is IDataContextAware) {
						var cntxCtrl = (IDataContextAware)Ctrl;
						if (cntxCtrl.DataContext != null)
							return cntxCtrl.DataContext.TryGetValue(key, out val);
					}
					return false;

			}
			return false;
		}


		#region IDictionary Members

		void IDictionary.Add(object key, object value) {
			throw new NotImplementedException();
		}

		void IDictionary.Clear() {
			throw new NotImplementedException();
		}

		bool IDictionary.Contains(object key) {
			if (!(key is string)) throw new ArgumentException();
			return this[(string)key] != null;
		}

		IDictionaryEnumerator IDictionary.GetEnumerator() {
			// lets create composite 
			var dict = new Hashtable();
			foreach (var source in Order.Reverse()) {
				switch (source) {
					case SourceType.Request:
						foreach (string key in Request.Params.Keys)
							if (key!=null)
								dict[key] = Request.Params[key];
						break;
					case SourceType.Attributes:
						if (Attributes!=null)
							foreach (string key in Attributes.Keys)
								if (key.StartsWith(AttributePrefix))
									dict[key] = Attributes[key];
						break;
					case SourceType.Route:
						var route = Route;
						foreach (var entry in route)
							dict[entry.Key] = entry.Value;
						break;
					case SourceType.DataContext:
						if (Ctrl is IDataContextAware) {
							var cntxCtrl = (IDataContextAware)Ctrl;
							if (cntxCtrl.DataContext != null)
								foreach (var entry in cntxCtrl.DataContext)
									dict[entry.Key] = entry.Value;
						}
						break;
				}
			}
			return dict.GetEnumerator();
		}

		bool IDictionary.IsFixedSize {
			get { return false; }
		}

		bool IDictionary.IsReadOnly {
			get { return true; }
		}

		ICollection IDictionary.Keys {
			get { throw new NotImplementedException(); }
		}

		void IDictionary.Remove(object key) {
			throw new NotImplementedException();
		}

		ICollection IDictionary.Values {
			get { throw new NotImplementedException(); }
		}

		object IDictionary.this[object key] {
			get {
				if (!(key is string)) throw new ArgumentException();
				return this[(string)key];
			}
			set {
				if (Ctrl is IDataContextAware && key is string) {
					var cntxCtrl = (IDataContextAware)Ctrl;
					if (cntxCtrl.DataContext != null)
						cntxCtrl.DataContext[(string)key] = value;
				}
			}
		}

		#endregion

		#region ICollection Members

		void ICollection.CopyTo(Array array, int index) {
			throw new NotImplementedException();
		}

		int ICollection.Count {
			get { throw new NotImplementedException(); }
		}

		bool ICollection.IsSynchronized {
			get { return false; }
		}

		object ICollection.SyncRoot {
			get { return this; }
		}

		#endregion

		#region IEnumerable Members

		IEnumerator IEnumerable.GetEnumerator() {
			throw new NotImplementedException();
		}

		#endregion
	}
}
