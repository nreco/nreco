using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Web;

using NReco.Application.Web;
using NI.Ioc;
using NI.Data;


namespace NReco.Examples.CrudWebForms {

	public class Authors {

		public IDictionary[] GetAll(object context) {
			return AppContext.ComponentFactory.GetComponent<IDalc>("dsDalc").LoadAllRecords(new Query("authors"));
		}

		public IDictionary[] GetAllCountries(object context) {
			return AppContext.ComponentFactory.GetComponent<IDalc>("dsDalc").LoadAllRecords(new Query("countries"));
		}

		public IDictionary[] GetCitiesByCountry(object countryId) {
			return AppContext.ComponentFactory.GetComponent<IDalc>("dsDalc").LoadAllRecords(
				new Query("cities", (QField)"country_id" == new QConst(countryId)));
		}

	}
}