import style from "./Table.module.css";

const Table = (props) => {
  const tableHead = props.header.map((items, hIndex) => (
    <th key={`h_${hIndex}`}>{items}</th>
  ));

  let tableBody = "";
  if (props.children) {
    tableBody = props.children.map((rows, rindex) => (
      <tr key={rindex}>
        {rows.map((cols, cindex) => (
          <td key={`${rows[0]}-${cindex}`}>{cols}</td>
        ))}
      </tr>
    ));
  }

  let tableFoot = null;
  if (props.footer) {
    tableFoot = props.footer.map((items, fIndex) => (
      <td key={`f_${fIndex}`}>{items}</td>
    ));
  }

  return (
    <table className={style.rTable}>
      <thead>
        <tr>{tableHead}</tr>
      </thead>
      <tbody>{tableBody}</tbody>
      {tableFoot && (
        <tfoot>
          <tr>{tableFoot}</tr>
        </tfoot>
      )}
    </table>
  );
};

export default Table;
