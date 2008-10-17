#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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
using System.Collections;
using System.Text;
using NReco.Collections;

namespace NReco.Converters {

	public abstract class GenericTypeConverter : ITypeConverter {

		protected abstract bool CanConvertFromGeneric {get;}
		protected abstract bool CanConvertToGeneric {get;}
		protected abstract Type GenDefIType {get;}
		protected abstract Type NonGenIType { get;}

		public GenericTypeConverter() {
		}

		public virtual bool CanConvert(Type fromType, Type toType) {
			Type fromGenIType = FindGenericInterface(fromType, GenDefIType);
			if (fromGenIType!=null &&
				CanConvertFromGeneric &&
				toType==NonGenIType)
				return true;
			bool toIsGenIType = toType.IsGenericType && toType.GetGenericTypeDefinition()==GenDefIType;
			if (toIsGenIType && CanConvertToGeneric &&
				fromType.GetInterface(NonGenIType.Name)==NonGenIType )
				return true;
			if (fromGenIType != null && toIsGenIType &&
				CanConvertFromGeneric && CanConvertToGeneric &&
				IsCompatGenArgs(fromGenIType, toType))
				return true;
			return false;
		}

		protected bool IsCompatGenArgs(Type fromGType, Type toGType) {
			Type[] fromArgs = fromGType.GetGenericArguments();
			Type[] toArgs = toGType.GetGenericArguments();
			if (fromArgs.Length!=toArgs.Length) return false;
			for (int i=0; i<fromArgs.Length; i++)
				if (!IsCompatibleGArg(i,fromArgs[i],toArgs[i]))
					return false;
			return true;
		}

		protected virtual bool IsCompatibleGArg(int idx, Type fromType, Type toType) {
			return false;
		}


		protected abstract object ConvertFromGeneric(object o, Type fromGenIType);
		protected abstract object ConvertToGeneric(object o, Type toGenIType);

		public virtual object Convert(object o, Type toType) {
			// from generic to non-generic/compat generic
			Type fromType = o.GetType();
			if (CanConvertFromGeneric) {
				Type gIType = FindGenericInterface(fromType,GenDefIType);
				if (gIType!=null && toType==NonGenIType) {
					return ConvertFromGeneric(o, gIType);
				}
				// is compatible generic?
				if (gIType!=null && toType.IsGenericType && 
					toType.GetGenericTypeDefinition()==GenDefIType &&
					CanConvertToGeneric &&
					IsCompatGenArgs(gIType, toType) ) {
					// 2 wrappers
					object nonGInstance = ConvertFromGeneric(o, gIType);
					return ConvertToGeneric( nonGInstance, toType );
				}

			}
			// from non-generic to generic
			if (toType.IsGenericType && CanConvertToGeneric && toType.GetGenericTypeDefinition()==GenDefIType) {
				if (fromType.GetInterface(NonGenIType.Name)==NonGenIType)
					return ConvertToGeneric(o, toType);
			}


			throw new InvalidOperationException();
		}

		protected object CreateGenericWrapper(Type gDefType, Type gIType, object o) {
			Type[] gArgTypes = gIType.GetGenericArguments();
			Type gWrpType = gDefType.MakeGenericType(gArgTypes);
			return Activator.CreateInstance(gWrpType,o);
		}

		protected bool ImplementsGenericInterface(Type gType, Type gInterface) {
			return FindGenericInterface(gType,gInterface)!=null;
		}

		protected Type FindGenericInterface(Type gType, Type gInterface) {
			// maybe gType is generic interface?
			if (gType.IsGenericType && gType.GetGenericTypeDefinition()==gInterface)
				return gType;
			
			string interfaceName = gInterface.Name;
			Type foundInterface = gType.GetInterface(interfaceName);
			if (foundInterface != null) {
				Type deff = foundInterface.GetGenericTypeDefinition();
				return (deff == gInterface) ? foundInterface : null;
			} 
			return null;
		}

	}

}
