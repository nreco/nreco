using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Web;
using System.Data;

using NReco.Application.Web;
using NI.Ioc;
using NI.Data;


namespace NReco.Examples.CrudWebForms {

	public class DataContext {

		public IDictionary[] GetAllAuthors(object context) {
			return AppContext.ComponentFactory.GetComponent<IDalc>("dsDalc").LoadAllRecords(new Query("authors"));
		}

		public object GetAuthorName(object authorId) {
			return AppContext.ComponentFactory.GetComponent<IDalc>("dsDalc").LoadValue(
				new Query("authors", (QField)"id" == new QConst(authorId)) { Fields = new[] { (QField)"name" } });
		}

		public IDictionary[] GetAllCountries(object context) {
			return AppContext.ComponentFactory.GetComponent<IDalc>("dsDalc").LoadAllRecords(new Query("countries"));
		}

		public IDictionary[] GetCitiesByCountry(object countryId) {
			return AppContext.ComponentFactory.GetComponent<IDalc>("dsDalc").LoadAllRecords(
				new Query("cities", (QField)"country_id" == new QConst(countryId)));
		}

		public void MassSetBookRating(object rating, IList bookIds) {
			AppContext.ComponentFactory.GetComponent<IDalc>("dsDalc").Update(
				new Query("books", new QueryConditionNode( (QField)"id", Conditions.In, new QConst(bookIds) ) ),
				new Hashtable() {
					{"rating", rating}
				}
			);
		}


		public void Init() {
			DataSet ds = HttpContext.Current.Session["dataset"] as DataSet;
			if (ds == null) {
				ds = CreateSampleDS();
				var r = ds.Tables["books"].NewRow();
				r["title"] = "Twenty Thousand Leagues Under the Sea";
				r["description"] = "Twenty Thousand Leagues Under the Sea is a classic science fiction novel by French writer Jules Verne published in 1870. It tells the story of Captain Nemo and his submarine Nautilus, as seen from the perspective of Professor Pierre Aronnax.";
				r["rating"] = 5;
				r["author_id"] = 1;
				ds.Tables["books"].Rows.Add(r);

				var author1Row = ds.Tables["authors"].NewRow();
				author1Row["name"] = "Jules Verne";
				author1Row["sex"] = "Male";
				ds.Tables["authors"].Rows.Add(author1Row);

				var author2Row = ds.Tables["authors"].NewRow();
				author2Row["name"] = "Steven King";
				author2Row["sex"] = "Male";
				ds.Tables["authors"].Rows.Add(author2Row);

				ds.AcceptChanges();
				HttpContext.Current.Session["dataset"] = ds;
			}

			AppContext.ComponentFactory.GetComponent<NI.Data.DataSetDalc>("dsDalc").PersistedDS = ds;
			AppContext.ComponentFactory.GetComponent<NI.Data.DataSetFactory>("dsFactory").Schemas = new[] {
				new NI.Data.DataSetFactory.SchemaDescriptor() {
					TableNames = new[] {"books", "authors", "book_to_author" },
					XmlSchema = ds.GetXmlSchema()
				}
			};
		}

		public static DataSet CreateSampleDS() {
			var ds = new DataSet();
			var bookTbl = ds.Tables.Add("books");
			var idCol = bookTbl.Columns.Add("id", typeof(int));
			idCol.AutoIncrement = true;
			idCol.AutoIncrementSeed = 1;
			bookTbl.PrimaryKey = new[] { idCol };

			bookTbl.Columns.Add("title", typeof(string));
			bookTbl.Columns.Add("description", typeof(string));
			bookTbl.Columns.Add("author_id", typeof(int));
			bookTbl.Columns.Add("rating", typeof(int));
			bookTbl.Columns.Add("available", typeof(bool)).DefaultValue = false;
			bookTbl.Columns.Add("country_id", typeof(int));
			bookTbl.Columns.Add("city_id", typeof(int));

			var authorTbl = ds.Tables.Add("authors");
			var authorIdCol = authorTbl.Columns.Add("id", typeof(int));
			authorIdCol.AutoIncrement = true;
			authorIdCol.AutoIncrementSeed = 1;
			authorTbl.PrimaryKey = new[] { authorIdCol };
			authorTbl.Columns.Add("name", typeof(string));
			authorTbl.Columns.Add("sex", typeof(string));

			var bookToAuthorTbl = ds.Tables.Add("book_to_author");
			var rBookIdCol = bookToAuthorTbl.Columns.Add("book_id", typeof(int));
			var rAuthorIdCol = bookToAuthorTbl.Columns.Add("author_id", typeof(int));
			bookToAuthorTbl.PrimaryKey = new[] { rBookIdCol, rAuthorIdCol };


			var countryTbl = ds.Tables.Add("countries");
			countryTbl.Columns.Add("id", typeof(int));
			countryTbl.Columns.Add("name", typeof(string));
			var c1 = countryTbl.NewRow();
			c1["id"] = 1;
			c1["name"] = "USA";
			countryTbl.Rows.Add(c1);
			var c2 = countryTbl.NewRow();
			c2["id"] = 2;
			c2["name"] = "Ukraine";
			countryTbl.Rows.Add(c2);

			var cityTbl = ds.Tables.Add("cities");
			cityTbl.Columns.Add("id", typeof(int));
			cityTbl.Columns.Add("name", typeof(string));
			cityTbl.Columns.Add("country_id", typeof(int));

			var t1 = cityTbl.NewRow();
			t1["id"] = 1;
			t1["name"] = "New York";
			t1["country_id"] = 1;
			cityTbl.Rows.Add(t1);

			var t2 = cityTbl.NewRow();
			t2["id"] = 2;
			t2["name"] = "Chicago";
			t2["country_id"] = 1;
			cityTbl.Rows.Add(t2);

			var t3 = cityTbl.NewRow();
			t3["id"] = 3;
			t3["name"] = "Kyiv";
			t3["country_id"] = 2;
			cityTbl.Rows.Add(t3);

			var t4 = cityTbl.NewRow();
			t4["id"] = 4;
			t4["name"] = "Lviv";
			t4["country_id"] = 2;
			cityTbl.Rows.Add(t4);

			return ds;
		}

	}
}