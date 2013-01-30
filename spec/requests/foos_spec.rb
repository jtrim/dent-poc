require 'spec_helper'

describe 'Foos', js: true do

  it 'adds foos properly' do
    visit foos_path
    click_link 'New Foo'
    fill_in 'foo-name', with: 'A Foo'
    click_button 'Submit'

    foo = Foo.find_by_name('A Foo')

    page.should have_content 'A Foo'
    page.should have_link 'Show', href: foo_path(foo)
    page.should have_link 'Edit', href: edit_foo_path(foo)
    page.should have_link 'Delete', href: foo_path(foo), "data-method" => 'delete'
    page.should_not have_css 'form'

    current_path.should == foos_path
  end

end
