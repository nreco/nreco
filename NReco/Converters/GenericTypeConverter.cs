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
			if (fromType.IsGenericType && CanConvertFromGeneric &&
				ImplementsGenericInterface(fromType, GenDefIType) &&
				toType==NonGenIType )
					return true;
			if (toType.IsGenericType && CanConvertToGeneric &&
				toType.GetGenericTypeDefinition()==GenDefIType &&
				fromType.GetInterface(NonGenIType.Name)==NonGenIType )
					return true;
			return false;
		}

		protected abstract object ConvertFromGeneric(object o, Type fromGenIType);
		protected abstract object ConvertToGeneric(object o, Type toGenIType);

		public virtual object Convert(object o, Type toType) {
			// from generic to non-generic
			Type fromType = o.GetType();
			if (fromType.IsGenericType && CanConvertFromGeneric) {
				Type gIType = FindGenericInterface(fromType,GenDefIType);
				if (gIType!=null && toType==NonGenIType) {
					return ConvertFromGeneric(o, gIType);
				}
			}
			// from non-generic collections to generic
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
