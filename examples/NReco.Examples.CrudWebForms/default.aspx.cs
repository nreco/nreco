using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Web;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

using NReco.Application.Web;
using NI.Ioc;
using NI.Data;

namespace NReco.Examples.EmptyWebForms {
	
	public partial class _default : System.Web.UI.Page {
		protected void Page_Load(object sender, EventArgs e) {

		}

		protected void Page_Init(object sender, EventArgs e) {
			DataSet ds = HttpContext.Current.Session["dataset"] as DataSet;
			if (ds == null) {
				ds = CreateBookDS();
				var r = ds.Tables["books"].NewRow();
				r["title"] = "Twenty Thousand Leagues Under the Sea";
				r["description"] = "Twenty Thousand Leagues Under the Sea is a classic science fiction novel by French writer Jules Verne published in 1870. It tells the story of Captain Nemo and his submarine Nautilus, as seen from the perspective of Professor Pierre Aronnax.";
				r["rating"] = 5;
				r["author_id"] = 1;
				ds.Tables["books"].Rows.Add(r);

				var author1Row = ds.Tables["authors"].NewRow();
				author1Row["name"] = "Jules Verne";
				ds.Tables["authors"].Rows.Add(author1Row);

				var author2Row = ds.Tables["authors"].NewRow();
				author2Row["name"] = "Steven King";
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

		public static DataSet CreateBookDS() {
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

			var authorTbl = ds.Tables.Add("authors");
			var authorIdCol = authorTbl.Columns.Add("id", typeof(int));
			authorIdCol.AutoIncrement = true;
			authorIdCol.AutoIncrementSeed = 1;
			authorTbl.PrimaryKey = new[] { authorIdCol };
			authorTbl.Columns.Add("name", typeof(string));

			var bookToAuthorTbl = ds.Tables.Add("book_to_author");
			var rBookIdCol = bookToAuthorTbl.Columns.Add("book_id", typeof(int));
			var rAuthorIdCol = bookToAuthorTbl.Columns.Add("author_id", typeof(int));
			bookToAuthorTbl.PrimaryKey = new[] { rBookIdCol, rAuthorIdCol };

			return ds;
		}
	}


}