using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Web.Script.Serialization;

using NReco.Collections;
using NReco.Converting;

namespace NReco.OGNL.Helpers
{
    public static class Json
    {
        public static object FromJsonString(string str)
        {
            return new JavaScriptSerializer().DeserializeObject(str);
        }

        public static string ToJsonString(object obj)
        {
            return new JavaScriptSerializer().Serialize(obj);
        }
    }
}
