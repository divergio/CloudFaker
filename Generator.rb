# -*- coding: utf-8 -*-
require 'moretext'
require 'faker'
require 'json'

class ChaseGenerator < Generator

  
  def initialize
    

    @chinese_text += MoreText.sentenses(30).join('')
    @chinese_text += MoreText.sentenses(30).join('')
    @chinese_text += MoreText.sentenses(30).join('')
    @chinese_text += MoreText.sentenses(30).join('')
  end


  def array_in_success_named(array, name)
    named_array = {}
    named_array[name] = array
    success = {}
    success['success'] = named_array
    return success
  end

  def dict_in_success_named(dict, name)
    named_dict = {}
    named_dict[name] = dict
    success = {}
    success['success'] = named_dict
    puts success
    return success
  end

  def random_comments(length=Random.rand(10))
    comments_array = Array.new(length)
    for i in 0..length
      comments_array[i] = random_comment()
    end
    return array_in_success_named(comments_array, "comments")
  end

  def random_comment
    comment = {}
    comment['commentId'] = random_id()
    
    #short and long comments
    if Random.rand(2) > 0
      comment['content'] = random_chinese(60,100)
    else
      comment['content'] = random_chinese(5,30)
    end
    comment['time'] = random_time()
    comment['author'] = random_author()

    return comment
  end

  def random_time
    now = Time.now
    two_years_ago = now - 60*60*24*365*2

    random_time = rand(two_years_ago..now)
    return random_time.strftime("%Y-%m-%d %T")
  end



  def random_posts(length,author={})
    posts_array = Array.new(length)
    for i in 0..length
      posts_array[i] = one_random_item()
      posts_array[i]['author'] = author
    end
    return array_in_success_named(posts_array,'posts')
  end

  def random_likes(length)
    likes_array = Array.new(length)
    for i in 0..length
      item = one_random_item()
      item['isLiked'] = true
      likes_array[i] = item 
    end
    return array_in_success_named(likes_array,'likes')
  end

  def random_followers(length,isFollow=true)
    followers_array = Array.new(length)
    for i in 0..length
      followers_array[i] = random_author()
      if isFollow == true
        followers_array[i]['isFollow'] = 1
      end

    end
    return array_in_success_named(followers_array,'followers')
  end

  def random_followings(length,isFollowed=true)
    followings_array = Array.new(length)
    for i in 0..length
      followings_array[i] = random_author()
      if isFollowed == true
        followings_array[i]['isFollowed'] = 1
      end
    end
    
    return array_in_success_named(followings_array,'followings')
  end

  def random_items(length, author={})  
    item_array = Array.new(length)
    for i in 0..length
      item_array[i] = one_random_item(author)
    end
    return array_in_success_named(item_array,'items')
  end

  def one_random_item(author={})
    item = {}
    item['images'] = random_images()
    item['title'] = random_title()
    item['description'] = random_description()
    item['price'] = random_item_price()
    item['categories'] = random_category_name()
    item['gender'] = Random.rand(2)
    if author == {}
      item['author'] = random_author()
    else
      item['author'] = author;
    end
    
    item['isPopular'] = Random.rand(2)
    item['isLiked'] = false
    
    #weight for more zeros
    if Random.rand(10) > 3
      item['commentNumber'] = Random.rand(100)
    else
      item['commentNumber'] = 0;
    end
    
    if Random.rand(10) > 3
      item['likeNumber'] = Random.rand(100)
    else
      item['likeNumber'] = 0;
    end

    item['id'] = random_id()
    return item
  end

  def random_options(length=5)
    options_array = Array.new(length)
    for i in 0..length
      options_array[i] = one_random_option()
    end
    return array_in_success_named(options_array,'options')
  end

  def one_random_option()
    sizes = ['小','中','大','特大']
    colors = ['黃色','灰色','藍色','綠色','黑色','紅色']
    style = ['合身','特長','短','長','一般']
    size_num = (Random.rand(20)+ 30).to_s
    return sizes.sample + ', ' + colors.sample + ', ' + style.sample + ', ' + size_num
  end
  #creating random items with specific properties overridden
  def random_items_with(length=10,gender={},store={},keywords={},categories={})
    item_array = Array.new(length)
    
    author = {}
    if !(store == {})
      author = random_author(1)
      author['userId'] = store
    end
    
    for i in 0..length
      item = {}

      if author == {}
        item = one_random_item()
      else
        item = one_random_item(author)
      end
      
      if !(gender == {})
        item['gender'] = gender
      end
      
      if !(keywords == {})
        item['description'] = keywords + item['description']
      end
      
      #assign random category from the category list
      if !(categories == {})
        category_array = categories.split(",")
        item['categories'] = category_array[Random.rand(category_array.length)]
      end
      
      item_array[i] = item
    end

    return array_in_success_named(item_array,'items')
  end

  #http://stackoverflow.com/a/88341/1016515
  def random_id
    o =  [('a'..'z'),('0'..'9'),('A'..'Z')].map{|i| i.to_a}.flatten
    string  =  (0...10).map{ o[rand(o.length)] }.join
    return string
  end

  def random_title
    return random_chinese(1,10)
  end

  def random_description
    return random_chinese(15,60)
  end

  def random_chinese(minlength,maxlength)
    start = Random.rand(@chinese_text.length - maxlength)
    length = Random.rand(maxlength-minlength)+minlength
    return @chinese_text[start,length]
  end

  def random_images
    string = ''
    for i in 1..(Random.rand(8)+1)
      string =  random_image + "," + string
    end
    
    return string.chomp(",")
  end

  def random_image(horizontal=600,vertical=600)
    image_categories = ['abstract','city','people','transport','animals','food','nature','business', 'nightlife', 'sports','cats','fashion','technics']
    image_category = image_categories[Random.rand(image_categories.length)]
    #append a random id to trick the cache
    return "http://lorempixel.com/" + horizontal.to_s + "/" + vertical.to_s + "/" + image_category + "/" + random_id()[0,5]
  end

  def random_item_price
    if Random.rand(2) > 0
      return Random.rand(10000) + 1
    else
      return 0;
    end
  end

  def random_category_name
    categories = ['MtShirt', 'MtankTop', 'MSuit', 'Mshirt', 'MPolo', 'MSweater', 'MAccess', 'MCoat', 'MShoes', 'MPants', 'MBag', 'MHat', 'FUndies', 'FtShirt', 'FShirt', 'FVest', 'FPolo', 'FSweater', 'FCoat', 'FKnitwear', 'FSilk', 'FSkirt', 'FPants', 'FDress', 'FSuit', 'FBag', 'FHat', 'FAccess', 'FShoes']
    return categories[Random.rand(categories.length)]
  end

  def random_author(isStore=-1)
    author = {}
    author['userId'] = random_id()

    name = Faker::Name.name
    userName = name.gsub(/\s+/, "").downcase
    author['userName'] = userName
    
    if (Random.rand(100) > 60)
      author['nickName'] = name
    else
      author['nickName'] = random_chinese(3,7)
    end

    author['isFollowed'] = Random.rand(2)
    author['isFollow'] = Random.rand(2)
    author['isRecommended'] = Random.rand(2)
    if isStore == -1
      author['isStore'] = Random.rand(2)
    else
      author['isStore'] = isStore
    end

    #add store stuff
    author['paymentType'] = '0/1/2'
    author['paymentDescription'] = 'Taipei/Fubon/bank/38323'

    return author
  end

end
