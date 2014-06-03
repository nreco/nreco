using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Linq;

using NUnit.Framework;
using NReco;
using NReco.Collections;
using NReco.Dsm.WebForms;

namespace NReco.Tests {

	[TestFixture]
	public class SiteControlExtensionTests {

		[Test]
		public void ControlTreeTraversal() {
			var p = new Page();
			p.Controls.Add(new TextBox() { ID = "t1" });
			var ph = new PlaceHolder();
			ph.Controls.Add(new TextBox() { ID = "t2" });
			ph.Controls.Add(new System.Web.UI.WebControls.Label() { ID = "l1" });
			p.Controls.Add(ph);

			Assert.AreEqual( 1,
					(from c in ControlUtils.GetChildren<System.Web.UI.WebControls.Label>(p)
					where c.ID == "l1" select c).Count() );

			Assert.AreEqual(2,
					(from c in ControlUtils.GetChildren<TextBox>(p) select c).Count());

			var t2 = (from c in ControlUtils.GetChildren<TextBox>(p) where c.ID == "t2" select c).Single();
			Assert.IsNotNull(t2);
			Assert.AreEqual(ph, (from c in ControlUtils.GetParents<PlaceHolder>(t2) select c).Single());
		}




	}
}
