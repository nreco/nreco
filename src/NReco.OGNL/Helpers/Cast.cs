using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Web.Script.Serialization;

using NReco.Converting;

namespace NReco.OGNL.Helpers
{
    public static class Cast
    {
        public static IProvider<object,object> Provider(object o) {
			return ConvertManager.ChangeType<IProvider<object, object>>(o);
        }

		public static IOperation<object> Operation(object o) {
			return ConvertManager.ChangeType<IOperation<object>>(o);
		}
	}
}
