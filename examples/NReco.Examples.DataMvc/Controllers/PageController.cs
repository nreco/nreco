using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Xml;
using System.IO;
using System.Net;
using System.Threading;

using System.Web.Security;
using NReco.Application.Web;
using NI.Ioc;
using NI.Data;

namespace Controllers {
	
	public class PageController : Controller {

		public ActionResult IndexPage() {
			return View();
		}

		public ActionResult InitDb() {
			var initSql = AppContext.ComponentFactory.GetComponent<string>("dataSchemaCreateSql");
			var db = AppContext.ComponentFactory.GetComponent<ISqlDalc>("db");
			db.ExecuteNonQuery(initSql);
			return new EmptyResult();
		}

		public ActionResult InvokeProvider(string arg) {
			var dataProvider = AppContext.ComponentFactory.GetComponent<Func<IDictionary<string,object>, object>>(arg);
			return Json( dataProvider(new Dictionary<string,object>()) );
		}

		public ActionResult AddUser() {
			var dataRowMapper = AppContext.ComponentFactory.GetComponent<DataRowDalcMapper>("dbDataRowMapper");			
			var firstName = Request["first_name"];
			var lastName = Request["last_name"];

			dataRowMapper.Insert( "users", new Dictionary<string,object>() {
				{"first_name", firstName},
				{"last_name", lastName}
			});

			return new EmptyResult();
		}

	}
}
