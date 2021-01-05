import React, {useState} from 'react';
require('./Nav.css');

import Icon from './icon';

const ICONS = {
  superuser: 'user-ninja',
  administrator: 'user-astronaut',
  editor: 'user-edit',
  viewer: 'user'
};

const Login = ({user}) => {
  if (!user) return null;

  let {first, last, permissions} = user;

  let role = (permissions[CONFIG.project_name] || {}).role;

  if (permissions.administration && permissions.administration.role == 'administrator') role = 'superuser';

  return (
    <div className='etna-login'>
      {first} {last}
      <Icon className='etna-user' icon={ ICONS[role] } title={role}/>
    </div>
  );
};

const Logo = ({LogoImage}) =>
  <div className='etna-logo'>
    <a href='/'>
      <LogoImage/>
    </a>
  </div>;

const Link = ({app}) => {
  let image = <img title={app} className='etna-link' src={ `/images/${app}.svg` }/>;

  let host_key = `${app}_host`;

  if (!CONFIG[host_key]) return image;

  let link = new URL(...[CONFIG.project_name, CONFIG[host_key]].filter(_=>_));

  return <a href={link}>{image}</a>;
}

const Links = ({currentApp}) => {
  let [ shown, setShown ] = useState(false);
  let apps = [ 'timur', 'metis', 'janus' ].filter(a => a != currentApp);

  if (!shown) return <div className='etna-links'>
    <div className='etna-links-show' onClick={ () => setShown(true) } >
      <Icon icon='bars'/>
    </div>
  </div>;

  return <div className='etna-links'>
    { apps.map( app => <Link key={app} app={app}/>) }
    <div className='etna-links-hide' onClick={ () => setShown(false) } >
      <Icon icon='bars'/>
    </div>
  </div>;
}

const Nav = ({logo, app, children, user}) => 
  <div className='etna-nav'>
    <Logo LogoImage={logo}/>
    {children && children.filter(_=>_).length ? children : <div style={{flex: 1}}/>}
    <Links currentApp={app}/>
    <Login user={user}/>
  </div>;

export default Nav;
