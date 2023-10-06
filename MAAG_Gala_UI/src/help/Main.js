import styles from "./Help.module.css";

import HomeScreenImg from "../assets/img/help/home.jpg";
import ChildrenImg from "../assets/img/help/children.jpg";
import AdminDrwUpdateImg from "../assets/img/help/admin_drawing_update.jpg";
import CheckSheetButtonsImg from "../assets/img/help/checksheet_buttons.jpg";
import PicklistImg from "../assets/img/help/picklist.jpg";
import NotesImg from "../assets/img/help/notes.jpg";

const Main = () => {
  return (
    <div className={styles.docdiv}>
      <h3>Application Documentation</h3>
      <p className={styles.subheading}>Introduction</p>
      <p>
        The Technical Document Viewer is an easy to use web application to view
        the Technical documentation items such as report and drawings. <br />
        It is also integrated with other features such as checking of the
        completed items as well as filling out CheckSheets.
      </p>
      <p className={styles.subheading}>User Interface</p>
      <img src={HomeScreenImg} alt="Home Screen" style={{ width: "100%" }} />
      <p>
        <strong>1 - Project Selection Dropdown</strong>
      </p>
      <p>
        In order to view the technical documentation the user will need to
        select the project form the project drop down. This drop down is
        searchable and typing out the project number will filter the project
        list to make the selection of the correct project easier. Once the
        project is selected, all the related user interface elements get
        populated with their respective values and those will be covered in the
        subsequent sections.
      </p>
      <p>
        <strong>2 - Header Menu</strong>
      </p>
      <p>
        The right side of the header has the following navigation icons.
        <ul>
          <li>
            <span className="icon-resize-full">
              <strong>Full Screen</strong>
            </span>{" "}
            - As the application is intended to be used on a tablet, this icon
            maximises the screen to have maximum use of the space available.
            Clicking on this icon again will reduce the screen to the normal
            mode.
          </li>
          <li>
            <span className="icon-home">
              <strong>Home</strong>
            </span>{" "}
            - This will return the user to the home screen if on Admin. Will
            only be visible if the user has admin rights.
          </li>
          <li>
            <span className="icon-admin">
              <strong>Admin</strong>
            </span>{" "}
            - This will take the user to the admin screen. Will only be visible
            if the user has admin rights.
          </li>
          <li>
            <span className="icon-logout">
              <strong>Logout</strong>
            </span>{" "}
            - Will log the user out of the application.
          </li>
        </ul>
      </p>
      <p>
        <strong>3 - Reports Menu</strong>
      </p>
      <p>
        When the project is selected the reports menu get populated with the
        list of reports available to view. This menu is divided into sections
        based on the Work Centers and the type of job or project. Each of these
        sections may or may not be visible depending on the access roles and
        permissions provided by the Admin as well.
        <ul>
          <li>CutList - At Work Centers</li>
          <li>Fabrication</li>
          <li>Operation Work Centers...</li>
          <li>Order Verification Report for Spare Parts</li>
          <li>PickList</li>
          <li>Customer</li>
          <li>Checksheets</li>
        </ul>
      </p>
      <p>
        All the work center reports sections lists out the Job numbers under
        those sections. The jobs are classified based on their status into
        different colors:
        <br />
        Black - Released
        <br />
        Green - Complete
        <br />
        Disabled - Firm : Cannot be clicked on
        <br />
      </p>
      <p>
        The Fabrication section will have all the Job numbers listed while the
        other sections only have the job numbers that they have under them.
      </p>
      <p>
        Clicking on the links will populate Drawing Menu in 3 and the PDF of the
        report in 4
      </p>
      <p>
        <strong>4 - Drawing Menu</strong>
      </p>
      <p>
        The Drawing Menu has the list of the drawings under the report that the
        user has clicked on from the Reports menu. Clicking on the drawings
        populates the PDF of the drawing into the View Pane. It also depending
        on the report populates the Ineraction pane on the right.
      </p>
      <p>
        The Drawing menu is searchable and the drawing numbers can be filtered
        using the search textbox.
      </p>
      <p>
        <strong>5 - Viewing Pane</strong>
      </p>
      <p>
        The viewing pane gets populated either by the PDF files or by the
        CheckSheets depending on what the user has clicked on from the Drawing
        menu.
      </p>
      <p>
        <strong>PDF Viewer - </strong>The PDF viewer is a standard PDF viewer
        that the user can interact with the view the reports or the drawings,
        with the scroll, zoom and pan functionality. The report or the drawing
        can be downloaded and printed from here as well.
      </p>
      <p>
        <strong>Check Sheets - </strong>When the user clicks on the Checksheets
        on the Reports Pane and then selects the corresponding CheckSheet the
        pane is populated with the checksheet that needs to be filled in. The
        user can fill in the details and hit the complete button. If the
        Checkshet is partially filled in, it is populated with any entries
        filled in earlier.
      </p>
      <p>
        <strong>6 - Interaction Pane</strong>
      </p>
      <p>
        Depending on the report, drawing or checksheet selected, the interection
        pane is populated with the avaialble functions for those items.
      </p>
      <p>
        <strong>Notes : </strong> For any of the selected items the user can
        enter Notes by clicking on the Manage Notes button. This will open a
        Manage Notes dialog, as shown below. Users can then enter the notes into
        this panel. The Notes that have been entered earlier can be deleted as
        well. Only the users who have created the notes can delete them.
        <br />
        <img src={NotesImg} alt="Notes Panel" />
      </p>
      <p>
        <strong>Drawings : </strong> When any of the drawings are clicked, the
        Drawing parent as well as the Children will be pulled up depending on
        what is applicable for that section. If the drawings with that number
        are avaialble in the system, the application will present the user with
        an eye <span className="icon-eye"></span> icon, clicking on which will
        bring up the corresponding drawing in the Viewing pane.
      </p>
      <p>
        <strong>Bill of Materials : </strong> The Bill of Materials table
        provides the functionality to select the completed items after the
        operations on them have been completed. Clicking on the items will turn
        the color green. Selecting all the items on the drawing will provide a
        check mark <span className="icon-ok"></span> on the Drawing menu
        indicating that all the items on that drawing have been marked.
        <br />
        <br />
        <img src={ChildrenImg} alt="Select Children" />
        <br />
        The selections of the BOM are carried over to the subsequent operations.
        For FAB, selecting all the BOM Items marks it complete. For the
        subsequent operations, selecting all the BOM items and the Complete Item
        marks the drawing as complete.
      </p>
      <p>
        <strong>Admin Update : </strong> If the user has Admin access this Admin
        Function panel is presented. This is only for Drawings and allows the
        user to mark the drawing for update. This will pull the drawings from
        Solidworks once again. This can be used by the Admin to update any of
        the drawings after the initial project creation.
        <br />
        <br />
        <img src={AdminDrwUpdateImg} alt="Select Children" />
      </p>
      <p>
        <strong>PickList : </strong> When the Picklist items are selected on the
        right pane, the user interface changes so that the person responsible
        for providing inventory can enter the number of items picked from
        inventory as shown below.
        <br />
        <br />
        <img src={PicklistImg} alt="Picklist" />
      </p>
      <p>
        <strong>CheckSheet : </strong> If the CheckSheet is being viewed or
        filled in the Interaction Pane presents the user with 2 buttons, Print
        Checksheet with Names or Print Checksheet without names. Clicking on
        either of these buttons, will convert the filled in Checksheet to a PDF
        file and present them in the Viewing Pane.
        <br />
        <br />
        <img src={CheckSheetButtonsImg} alt="CheckSheet buttons" />
      </p>
      <p>
        Each of the menus as well as the interaction pane can be opened and
        closed using the open and close icon provided.
      </p>
      <p className={styles.subheading}>Contact Information</p>
      <p>
        Clicking on the Contact us section at the bottom of the page brings up
        the person to contact for any help requried.
      </p>
    </div>
  );
};

export default Main;
