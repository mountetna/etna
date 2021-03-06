import React, {Component} from 'react';
import Link from '../../../components/link';

const Dot = ({point, xmedian, label, model, color}) => {
  let dot = (
    <g>
      <circle cx={point.x} cy={point.y} r={2.5} fill={color} />
      {label && (
        <text
          textAnchor={point.x > xmedian ? 'end' : 'start'}
          x={point.x + (point.x > xmedian ? -4 : 4)}
          y={point.y}
        >
          {label}
        </text>
      )}
    </g>
  );
  return (
    <g className='dot'>
      {model && label ? (
        <Link
          link={Routes.browse_model_path(CONFIG.project_name, model, label)}
        >
          {dot}
        </Link>
      ) : (
        dot
      )}
    </g>
  );
};
export default class Scatter extends Component {
  render() {
    let {series, xScale, yScale, color} = this.props;
    let {
      name,
      variables: {x, y, label, model, nodeColor}
    } = series;
    let points = x.map((l, v, i) => ({x: xScale(x(i)), y: yScale(y(i))}));

    // If each dot's color is specified in the series, use that.
    // Otherwise default to the props value sent in.
    let nodeColors = nodeColor
      ? nodeColor
      : new Array(points.length).fill(color);

    let labels = label ? label.values : x.labels;

    let xmedian =
      (parseInt(xScale.range()[0]) + parseInt(xScale.range()[1])) / 2;

    return (
      <g className='scatter-series'>
        {points.map((point, index) => (
          <Dot
            key={`cir_${index}`}
            point={point}
            xmedian={xmedian}
            label={labels[index]}
            model={model}
            color={nodeColors[index]}
          />
        ))}
      </g>
    );
  }
}
