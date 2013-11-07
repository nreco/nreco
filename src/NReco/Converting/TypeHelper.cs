﻿#region License
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
using System.Reflection;

namespace NReco.Converting {
	
	public static class TypeHelper {

		public static bool IsNullable(Type t) {
			return t.IsGenericType && t.GetGenericTypeDefinition() == typeof(Nullable<>);
		}

		public static bool IsDelegate(Type t) {
			return typeof(Delegate).IsAssignableFrom(t);
		}

		public static Type FindGenericInterface(Type gType, Type gInterface) {
			// maybe gType is generic interface?
			if (gType.IsGenericType && gType.GetGenericTypeDefinition() == gInterface)
				return gType;

			string interfaceName = gInterface.Name;
			Type[] foundInterfaces = gType.FindInterfaces(Module.FilterTypeName, interfaceName);
			if (foundInterfaces != null)
				for (int i = 0; i < foundInterfaces.Length; i++) {
					Type deff = foundInterfaces[i].GetGenericTypeDefinition();
					if (deff == gInterface)
						return foundInterfaces[i];
				}
			return null;
		}

		public static bool IsFunctionalInterface(Type iType) {
			if (!iType.IsGenericTypeDefinition && iType.IsInterface) {
				// ensure that interface contains only 1 method
				if (iType.GetFields().Length == 0 && iType.GetEvents().Length == 0 &&
					iType.GetProperties().Length == 0 && iType.GetMethods().Length==1) {
						return true;
				}
			}
			return false;
		}

	}
}
