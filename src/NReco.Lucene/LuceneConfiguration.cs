using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Web;

namespace NReco.Lucene
{
   public class LuceneConfiguration
   {
       private string _IndexPath;
       public string IndexPath
       {
           get
           {
               if (!Path.IsPathRooted(_IndexPath))
               {
                   _IndexPath = Path.Combine(HttpRuntime.AppDomainAppPath, _IndexPath);
               }
               return _IndexPath;
           }
           set { _IndexPath = value; }
       }
   }
}
